# frozen_string_literal: true

module Documents
  module Statements
    class Example < Statement
      def initialize(filepath:)
        csv_import_options = { col_sep: ';', headers: true }

        super(filepath: filepath, csv_import_options: csv_import_options)
      end
    end
  end
end
