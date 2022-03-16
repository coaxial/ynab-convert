# frozen_string_literal: true

require 'ynab_convert/documents/statements/statement'

module Documents
  module Statements
    # Example of a Statement
    class Example < Statement
      def initialize(filepath:)
        csv_import_options = { col_sep: ';', quote_char: nil, headers: true }

        super(filepath: filepath, csv_import_options: csv_import_options)
      end
    end
  end
end
