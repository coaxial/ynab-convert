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
      file_uuid = rand(36**8).to_s(36)
    end

    def to_ynab!
      convert!
    end

    # def to_ynab
    #   raise NotImplementedError, :to_ynab
    # end

    # # Converts @file to YNAB 4 CSV format and writes it out to a new file
    # # c.f. https://docs.youneedabudget.com/article/921-formatting-csv-file
    # # @param row [CSV::Row] The rows to write out
    # def to_ynab!(converted_csv)
    #   headers = %w[Date Payee Memo Outflow Inflow]
    #   CSV.open(output_filename, 'wb', write_headers: true, headers: headers) do |csv|
    #     csv << converted_csv
    #   end
    # end

    protected

    attr_accessor :file_uuid, :statement_from, :statement_to

    def convert!
      CSV.open(temp_filename, 'wb', output_options) do |converted|
        CSV.foreach(@file, 'rb', loader_options) do |row|
          extract_statement_interval_dates(row)
          converted << converters(row)
        end
      end

      File.rename(temp_filename, output_filename)
    end

    def institution_name
      @institution_name.snake_case
    end

    def temp_filename
      "#{File.basename(@file, '.csv')}_#{institution_name}_#{file_uuid}_ynab4.csv"
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
        converters: %i[numeric date], force_quotes: true, write_headers: true, headers: ynab_headers
      }
    end

    def converters
      raise NotImplementedError, :converters
    end
  end
end
