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
  class Example < Processor::Base
    # @option options [String] :file Path to the CSV file to process
    def initialize(options)
      # These are the options for the CSV module (see
      # https://ruby-doc.org/stdlib-2.6/libdoc/csv/rdoc/CSV.html#method-c-new)
      # They should match the format for the CSV file that the financial
      # institution generates.
      @loader_options = {
        col_sep: ';',
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

    protected

    # Converts the institution's CSV rows into YNAB4 rows.
    # The YNAB4 columns are:
    # "Date', "Payee", "Memo", "Outflow", "Inflow"
    # which match Example Bank's "transaction_date" (after parsing),
    # "beneficiary", nothing, "debit", and "credit" respectively.
    # Note that Example Bank doesn't include any relevant column for YNAB4's
    # "Memo" column so it's skipped and gets '' as its value.
    def converters(row)
      transaction_date = extract_transaction_date(row)

      # Convert the original transaction_date to DD/MM/YYYY as YNAB4 expects it.
      [transaction_date.strftime('%d/%m/%Y'),
       row['beneficiary'],
       '',
       row['debit'] || '',
       row['credit'] || '']
    end

    # Extracts and casts transaction dates to a Date object. This is used to
    # generate the YNAB4 CSV file's name.
    def extract_transaction_date(row)
      # The date's format in the institution's CSV is "DD.MM.YYYY".
      Date.strptime(row['transaction_date'], '%d.%m.%y')
    end
  end
end
