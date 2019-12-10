# frozen_string_literal: true

module Processor
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
  class Example < Processor::Base
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
        col_sep: ';',
        # Use your converters, if any
        converters: %i[my_converter transaction_date],
        headers: true
      }

      # This is the financial institution's full name as it calls itself. This
      # usually matches the institution's letterhead and/or commercial name.
      # It can happen that the same institution needs different parsers because
      # its credit card CSV files are in one format, and its chequing accounts
      # in another. In that case, more details can be added in parens.
      # For instance:
      # 'Example Bank (credit cards)' and 'Example Bank (chequing)'
      @institution_name = 'Example Bank'

      # This is mandatory.
      super(options)
    end

    private

    def register_custom_converters
      CSV::Converters[:transaction_date] = lambda { |s|
        # Only match strings that have two digits, a dot, two digits, a dot,
        # two digits, i.e. the dates in this institution's CSV files.
        if !s.nil? && /\d{2}\.\d{2}\.\d{2}/.match(s)
          return Date.strptime(s, '%d.%m.%y')
        end

        s
      }
      CSV::Converters[:my_converter] = lambda { |s|
        # A contrived example, just to illustrate multiple converters
        return s.downcase if s.respond_to?(:downcase)

        s
      }
    end

    protected

    # Converts the institution's CSV rows into YNAB4 rows.
    # The YNAB4 columns are:
    # "Date', "Payee", "Memo", "Outflow", "Inflow"
    # which match Example Bank's "transaction_date" (after parsing),
    # "beneficiary", nothing, "debit", and "credit" respectively.
    # Note that Example Bank doesn't include any relevant column for YNAB4's
    # "Memo" column so it's skipped and gets '' as its value.
    # rubocop:disable Metrics/AbcSize
    def converters(row)
      transaction_date = row[headers[:transaction_date]]
      payee = row[headers[:payee]]
      debit = row[headers[:debit]]
      credit = row[headers[:credit]]
      # CSV files can have funny data in them, including invalid or empty rows.
      # These rows can be skipped from the converted YNAB4 file by calling
      # skip_row when detected. In this particular case, if there is no
      # transaction date, it means the row is empty or invalid and we discard
      # it.
      skip_row(row) if transaction_date.nil?

      [
        # Convert the original transaction_date to DD/MM/YYYY as YNAB4 expects
        # it.
        transaction_date.strftime('%d/%m/%Y'),
        payee,
        '',
        debit,
        credit
      ]
    end
    # rubocop:enable Metrics/AbcSize

    private

    # Institutions love translating the column names, apparently. Rather than
    # hardcoding the column name as a string, use the headers array at the
    # right index.
    # These lookups aren't particularly expensive but they're done on each row
    # so why not memoize them with ||=
    def extract_header_names(row)
      headers[:transaction_date] ||= row.headers[0]
      headers[:payee] ||= row.headers[2]
      headers[:debit] ||= row.headers[3]
      headers[:credit] ||= row.headers[4]
    end
  end
end
