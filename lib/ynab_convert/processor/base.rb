# frozen_string_literal: true

require 'core_extensions/string'
require 'csv'
require 'ynab_convert/logger'
require 'ynab_convert/config'

module Processor
  # Base class for a Processor, all processors must inherit from it.

  # rubocop:disable Metrics/ClassLength
  class Base
    include YnabLogger
    include CoreExtensions::String::Inflections

    attr_reader :loader_options

    # @param [Hash] options The options to instantiate the processor
    # @option options [String] :file Path to the CSV file to process
    # @option options [Symbol] :format YNAB4 format to use, one of :flows or
    #   :amounts. :flows is useful for CSVs with separate debit and credit
    #   columns, :amounts is for CSVs with only one amount columns and +/-
    #   numbers. See
    #   https://docs.youneedabudget.com/article/921-formatting-csv-file
    # @option options [YnabConvert::Config] :config Override the default Config
    #   object. Typically used for testing with mocks and doubles.
    def initialize(options)
      default_options = { file: '', format: :flows, config: YnabConvert::Config.new }
      opts = default_options.merge(options)

      logger.debug "Initializing processor with options: `#{opts.to_h}'"
      raise ::Errno::ENOENT unless File.exist? opts[:file]

      @file = opts[:file]
      @headers = { transaction_date: nil, payee: nil }
      @format = opts[:format]
      @config = opts[:config]

      if @format == :amounts
        amounts_columns = { amount: nil }
        @headers.merge!(amounts_columns)
      else
        flows_columns = { inflow: nil, outflow: nil }
        @headers.merge!(flows_columns)
      end
    end

    def to_ynab!
      begin
        convert!
        rename_file
      rescue YnabConvert::Error
        invalid_csv_file
      end
    ensure
      logger.debug "Deleting temp file `#{temp_filename}'"
      delete_temp_csv
    end

    protected

    attr_accessor :statement_from, :statement_to, :headers

    def amount_invalid?(row)
      amount_index = 3

      # If there is no amount,
      # then the row is invalid.
      row[amount_index].nil? || row[amount_index].empty?
    end

    def inflow_outflow_invalid?(row)
      inflow_index = 3
      outflow_index = 4

      # If there is neither inflow and outflow values,
      # or both the inflow and outflow amounts are 0,
      # then the row is invalid.
      (
        row[inflow_index].nil? ||
        row[inflow_index].empty? ||
        row[inflow_index] == '0.00'
      ) && (
        row[outflow_index].nil? ||
        row[outflow_index].empty? ||
        row[outflow_index] == '0.00'
      )
    end

    def amounts_missing?(row)
      logger.debug "Checking for missing amount in `#{row}`"
      if @format == :amounts
        logger.debug 'Using `:amounts`'
        amount_invalid?(row)
      else
        logger.debug 'Using `:flows`'
        inflow_outflow_invalid?(row)
      end
    end

    def skip_row(row)
      logger.debug "Found empty row, skipping it: #{row.to_h}"
      throw :skip_row
    end

    def delete_temp_csv
      FileUtils.remove_file temp_filename, force: true
    end

    def transaction_date_missing?(ynab_row)
      ynab_row[0].nil? || [0].empty?
    end

    def extract_transaction_date(ynab_row)
      transaction_date_index = 0
      ynab_row[transaction_date_index]
    end

    def record_statement_interval_dates(ynab_row)
      transaction_date_index = 0
      date = Date.parse(ynab_row[transaction_date_index])

      if date_is_further_away?(date)
        logger.debug "Replacing statement_from `#{statement_from.inspect}' "\
          "with `#{date}'"
        self.statement_from = date
      end
      # rubocop:disable Style/GuardClause
      if date_is_more_recent?(date)
        logger.debug "Replacing statement_to `#{statement_to.inspect}' with "\
          "`#{date}'"
        self.statement_to = date
      end
      # rubocop:enable Style/GuardClause
    end

    def date_is_more_recent?(date)
      statement_to.nil? || statement_to < date
    end

    def date_is_further_away?(date)
      statement_from.nil? || statement_from > date
    end

    def convert!
      logger.debug "Will write to `#{temp_filename}'"

      logger.debug(loader_options)
      CSV.open(temp_filename, 'wb', **output_options) do |converted|
        CSV.foreach(@file, 'rb', **loader_options) do |row|
          logger.debug "Parsing row: `#{row.to_h}'"
          # Some rows don't contain valid or useful data
          catch :skip_row do
            extract_header_names(row)
            transformed_row = transformers(row)
            if amounts_missing?(transformed_row) ||
               transaction_date_missing?(transformed_row)
              logger.debug 'Empty row, skipping it'
              skip_row(row)
            end
            ynab_row = transformed_row
            if currency_conversion_needed?
              ynab_row = convert_amounts(transformed_row)
            end
            converted << ynab_row
            record_statement_interval_dates(ynab_row)
          end

          logger.debug 'Done converting'
        end
      end
    end

    def rename_file
      File.rename(temp_filename, output_filename)
      logger.debug "Renamed temp file `#{temp_filename}' to "\
        "`#{output_filename}'"
    end

    def invalid_csv_file
      raise YnabConvert::Error, "Unable to parse file `#{@file}'. Is it a "\
        "valid CSV file from #{@institution_name}?"
    end

    def file_uid
      @file_uid ||= rand(36**8).to_s(36)
    end

    def temp_filename
      "#{File.basename(@file, '.csv')}_#{@institution_name.snake_case}_"\
        "#{file_uid}_ynab4.csv"
    end

    def output_filename
      # If the file contained no parsable CSV data, from and to dates will be
      # nil.
      # This is to avoid a NoMethodError on NilClass.
      raise YnabConvert::Error if statement_from.nil? || statement_to.nil?

      from = statement_from.strftime('%Y%m%d')
      to = statement_to.strftime('%Y%m%d')

      "#{File.basename(@file, '.csv')}_#{@institution_name.snake_case}_"\
        "#{from}-#{to}_ynab4.csv"
    end

    def ynab_headers
      common_headers = %w[Date Payee Memo]

      if @format == :amounts
        amounts_headers = %w[Amount]
        common_headers.concat(amounts_headers)
      else
        flows_headers = %w[Outflow Inflow]
        common_headers.concat(flows_headers)
      end

      common_headers
    end

    def output_options
      {
        converters: %i[numeric date],
        force_quotes: true,
        write_headers: true,
        headers: ynab_headers
      }
    end

    # After the individual cells have been parsed from the raw CSV to Ruby
    # primitives with `register_custom_converters` and CSV::Converters, this
    # method will map the statement's CSV columns to YNAB4 columns (namely:
    # "date", "payee", "memo", and "debit" + "credit" or "amount").
    def transformers
      raise NotImplementedError, :transformers
    end

    def currency_conversion_needed?
      processor_name = self.class.name.split('::').last
      config = @config.get(key: processor_name)

      config.key?(:TargetCurrency)
    end

    # Convert the amounts on a given row into YNAB4 budget's currency.
    def convert_amount(row)
      row
    end
  end
  # rubocop:enable Metrics/ClassLength
end
