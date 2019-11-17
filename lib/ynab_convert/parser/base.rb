# frozen_string_literal: true

require 'core_extensions/string'

module Parser
  # Base class for a Parser
  class Base
    attr_reader :institution_name

    # @option opts [String] :institution_name Name of the financial institution
    # this parser is for (Example: "Iron Bank of Braavos")
    # @option opts [String] :file Path to the CSV file to process
    def initialize(opts)
      @institution_name = opts[:institution_name].snake_case
      @file = opts[:file]
    end

    # Converts @file to YNAB 4 CSV format and writes it out to a new file
    # c.f. https://docs.youneedabudget.com/article/921-formatting-csv-file
    # @param row [CSV::Row] The rows to write out
    def to_ynab!(row)
      CSV.open(output_filename, 'wb') do |csv|
        csv << row
      end
    end

    protected

    # @option opts [Time] :from Timestamp of first recorded transaction in the
    # statement
    # @option opts [Time] :to Timestamp of last recorded transaction in the
    # statement
    def output_filename(opts)
      from = opts[:from].strftime('%Y%m%d')
      to = opts[:to].strftime('%Y%m%d')

      "#{File.basename(@file, '.csv')}_#{@institution_name}_#{from}-" \
        "#{to}_ynab4.csv"
    end
  end
end
