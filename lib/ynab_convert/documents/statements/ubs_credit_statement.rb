# frozen_string_literal: true

module Documents
  module Statements
    # UBS Switzerland Credit Card accounts statement
    class UBSCredit < Statement
      def initialize(filepath:)
        csv_import_options = {
          col_sep: ';',
          quote_char: nil,
          headers: true,
          encoding: "#{Encoding::ISO_8859_1}:#{Encoding::UTF_8}",
          skip_lines: 'sep=;'
        }
        super(filepath: filepath, csv_import_options: csv_import_options)
      end
    end
  end
end
