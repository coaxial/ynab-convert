# frozen_string_literal: true

module Documents
  module Statements
    # Wise card accounts statement
    class Wise < Statement
      def initialize(filepath:)
        csv_import_options = {
          col_sep: ',',
          quote_char: '"',
          headers: true
        }
        super(filepath: filepath, csv_import_options: csv_import_options)
      end
    end
  end
end
