# frozen_string_literal: true

module Processor
  # Processes CSV files from N26
  #
  # An example of how to implement a custom processor
  # Processes CSV files with this format:
  # <<~ROWS
  # "Date","Payee","Memo","Outflow","Inflow"
  # "23/12/2019","coaxial","","1000000.00",""
  # "30/12/2019","Santa","","50000.00",""
  # "02/02/2020","Someone Else","","45.00",""
  # ROWS
  # The file name for the processor should be the institution name in
  # camel case. It's ok to skip "Bank" or "Credit Union" when naming the file
  # if it's redundant. For instance, this parser is for "Example Bank" but it's
  # named "example.rb", its corresponding spec is
  # "spec/example_processor_spec.rb" and its fixture would be
  # "spec/fixtures/example.csv"
  class N26 < Processor::Base
    # @option options [String] :file Path to the CSV file to process
    def initialize(options)
      # Custom converters can be added so that the CSV data is parsed when
      # loading the original file
      register_custom_converters

      # These are the options for the CSV module (see
      # https://ruby-doc.org/stdlib-2.6/libdoc/csv/rdoc/CSV.html#method-c-new)
      # They should match the format for the CSV file that the financial
      # institution generates.
      @loader_options = {
        col_sep: ',',
        quote_char: '"',
        # Use your converters, if any
        # converters: %i[],
        headers: true,
        encoding: 'bom|utf-8'
      }

      # This is the financial institution's full name as it calls itself. This
      # usually matches the institution's letterhead and/or commercial name.
      # It can happen that the same institution needs different parsers because
      # its credit card CSV files are in one format, and its chequing accounts
      # in another. In that case, more details can be added in parens.
      # For instance:
      # 'Example Bank (credit cards)' and 'Example Bank (chequing)'
      @institution_name = 'N26 Bank'
      # N26's CSV only has one columns for all transactions instead of separate
      # debit and credit columns
      additional_processor_options = { format: :amounts }

      # This is mandatory.
      super(options.merge(additional_processor_options))
    end

    private

    def register_custom_converters; end

    protected

    def transformers(row)
      transaction_date = row[headers[:transaction_date]]
      payee = row[headers[:payee]]
      amount = row[headers[:amount]]

      converted_row = [transaction_date, payee, nil, amount]
      logger.debug "Converted row: #{converted_row}"
      converted_row
    end

    private

    # Institutions love translating the column names, apparently. Rather than
    # hardcoding the column name as a string, use the headers array at the
    # right index.
    # These lookups aren't particularly expensive but they're done on each row
    # so why not memoize them with ||=
    def extract_header_names(row)
      headers[:transaction_date] ||= row.headers[0]
      headers[:payee] ||= row.headers[1]
      headers[:amount] ||= row.headers[5]
    end
  end
end
