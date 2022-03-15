# frozen_string_literal: true

require 'ynab_convert/documents/statements/statement'

module Documents
  module Statements
    # Represents a statement from N26 Bank
    class N26 < Statement
      # @param filepath [String] Path to CSV statement
      # @return [void]
      def initialize(filepath:)
        csv_import_options = {
          col_sep: ',',
          quote_char: '"',
          headers: true,
          encoding: 'bom|utf-8'
        }

        super(filepath: filepath,
              csv_import_options: csv_import_options,)
      end
    end
  end
end
