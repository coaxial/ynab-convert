# frozen_string_literal: true

require 'core_extensions/string'
require 'csv'
require 'ynab_convert/logger'

module Processor
  # Base class for a Processor, all processors must inherit from it
  # rubocop:disable Metrics/ClassLength
  class Base
    include YnabLogger
    include CoreExtensions::String::Inflections

    attr_reader :loader_options

    # @option opts [String] :file Path to the CSV file to process
    def initialize(opts)
      logger.debug "Initializing processor with options: `#{opts.to_h}'"
      raise ::Errno::ENOENT unless File.exist? opts[:file]

      @file = opts[:file]
      @headers = { transaction_date: nil, payee: nil, debit: nil, credit: nil }
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

    def inflow_or_outflow_missing?(row)
      inflow_index = 3
      outflow_index = 4
      # If there is neither inflow and outflow values, or their value is 0,
      # then the row is not valid to YNAB4
      (row[inflow_index].nil? || row[inflow_index].empty? ||
       row[inflow_index] == '0.00') &&
        (row[outflow_index].nil? || row[outflow_index].empty? ||
         row[outflow_index] == '0.00')
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

      CSV.open(temp_filename, 'wb', output_options) do |converted|
        CSV.foreach(@file, 'rb', loader_options) do |row|
          logger.debug "Parsing row: `#{row.to_h}'"
          # Some rows don't contain valid or useful data
          catch :skip_row do
            extract_header_names(row)
            ynab_row = transformers(row)
            if inflow_or_outflow_missing?(ynab_row) ||
               transaction_date_missing?(ynab_row)
              logger.debug 'Empty row, skipping it'
              skip_row(row)
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
      %w[Date Payee Memo Outflow Inflow]
    end

    def output_options
      {
        converters: %i[numeric date],
        force_quotes: true,
        write_headers: true,
        headers: ynab_headers
      }
    end

    def transformers
      raise NotImplementedError, :transformers
    end
  end
  # rubocop:enable Metrics/ClassLength
end
