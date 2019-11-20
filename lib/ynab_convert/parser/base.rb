# frozen_string_literal: true

require 'core_extensions/string'
require 'csv'

module Parser
  # Base class for a Parser
  class Base
    attr_reader :loader_options

    # @option opts [String] :file Path to the CSV file to process
    def initialize(opts)
      @file = opts[:file]
    end

    def to_ynab!
      convert!
    end

    protected

    attr_accessor :statement_from, :statement_to

    def extract_transaction_date(_row)
      raise NotImplementedError, :extract_transaction_date
    end

    def record_statement_interval_dates(row)
      date = extract_transaction_date(row)

      self.statement_from = date if statement_from.nil? || statement_from > date
      self.statement_to = date if statement_to.nil? || statement_to < date
    end

    def convert!
      CSV.open(temp_filename, 'wb', output_options) do |converted|
        CSV.foreach(@file, 'rb', loader_options) do |row|
          record_statement_interval_dates(row)
          converted << converters(row)
        end
      end

      File.rename(temp_filename, output_filename)
    end

    def institution_name
      @institution_name.snake_case
    end

    def file_uid
      @file_uid = rand(36**8).to_s(36) if @file_uid.nil?
      @file_uid
    end

    def temp_filename
      "#{File.basename(@file, '.csv')}_#{institution_name}_#{file_uid}" \
        '_ynab4.csv'
    end

    def output_filename
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
