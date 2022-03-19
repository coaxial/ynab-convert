# frozen_string_literal: true

module Documents
  module Statements
    # UBS Switzerland Chequing accounts statement
    class UBSChequing < Statement
      # @param filepath [String] path to CSV statement
      def initialize(filepath:)
        csv_import_options = {
          col_sep: ';',
          quote_char: nil,
          encoding: Encoding::UTF_8,
          headers: true
        }

        super(filepath: filepath, csv_import_options: csv_import_options)
      end
    end
  end
end
