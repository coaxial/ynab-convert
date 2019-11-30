# frozen_string_literal: true

require 'core_extensions/string'
require 'csv'
require 'ynab_convert/logger'

module Processor
  # Base class for a Processor
  class Base
    include YnabLogger
    include CoreExtensions::String::Inflections

    attr_reader :loader_options

    # @option opts [String] :file Path to the CSV file to process
    def initialize(opts)
      raise ::Errno::ENOENT unless File.exist? opts[:file]

      @file = opts[:file]

      logger.debug "Processor for `#{@institution_name}' initialized"
    end

    def to_ynab!
      convert!
    ensure
      logger.debug "Deleting temp file `#{temp_filename}'"
      temp_csv_deleted
    end

    protected

    attr_accessor :statement_from, :statement_to

    def temp_csv_deleted
      FileUtils.remove_file temp_filename, force: true
    end

    def extract_transaction_date
      raise NotImplementedError, :extract_transaction_date
    end

    def record_statement_interval_dates(row)
      date = extract_transaction_date(row)

      logger.debug "Found date in statement: `#{date}'"

      if date_is_further_away(date)
        self.statement_from = date
        logger.debug "New date `#{date}' supercedes current statement_from date `#{statement_from}'"
      end

      if date_is_more_recent(date)
        self.statement_to = date
        logger.debug "New date `#{date}' supercedes current statement_to date `#{statement_to}'"
      end
    end

    def date_is_more_recent(date)
      statement_to.nil? || statement_to < date
    end

    def date_is_further_away(date)
      statement_from.nil? || statement_from > date
    end

    def convert!
      logger.debug "Will write to `#{temp_filename}'"

      CSV.open(temp_filename, 'wb', output_options) do |converted|
        CSV.foreach(@file, 'rb', loader_options) do |row|
          logger.debug "Parsing row: `#{row.to_h}'"

          record_statement_interval_dates(row)
          converted << converters(row)
        end

        logger.debug 'Done converting'
      end

      File.rename(temp_filename, output_filename)
      logger.debug "Renamed temp file `#{temp_filename}' to "\
        "`#{output_filename}'"
    end

    def invalid_csv_file
      raise "Unable to parse file `#{@file}'. Is it a valid"\
       " CSV file from #{@institution_name}?"
    end

    def institution_name
      @institution_name.snake_case
    end

    def file_uid
      @file_uid ||= rand(36**8).to_s(36)
    end

    def temp_filename
      @temp_filename ||= "#{File.basename(@file, '.csv')}_#{institution_name}" \
        "_#{file_uid}_ynab4.csv"
      @temp_filename
    end

    def output_filename
      # if these dates are nil, the CSV file couldn't be parsed with this
      # processor.
      invalid_csv_file if statement_from.nil? || statement_to.nil?

      from = statement_from.strftime('%Y%m%d')
      to = statement_to.strftime('%Y%m%d')

      "#{File.basename(@file, '.csv')}_#{institution_name}_#{from}-" \
        "#{to}_ynab4.csv"
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

    def converters
      raise NotImplementedError, :converters
    end
  end
end
