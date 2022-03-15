# frozen_string_literal: true

require 'ynab_convert/documents'
require 'ynab_convert/transformers'
require 'ynab_convert/processors/processor'

module Processors
  # Processor for N26 statements
  class N26 < Processor
    # @param filepath [String] path to the CSV file
    def initialize(filepath:)
      csv_import_options = {
        col_sep: ',',
        quote_char: '"',
        headers: true,
        encoding: 'bom|utf-8'
      }
      transformers = [
        Transformers::Cleaners::N26.new,
        Transformers::Formatters::N26.new,
        Transformers::Enhancers::N26.new
      ]
      statement = Documents::Statements::Statement.new(filepath: filepath,
                                                       csv_import_options:
                                            csv_import_options)
      ynab4_file = Documents::YNAB4Files::YNAB4File.new(format: :amounts,
                                                        institution_name:
                                             statement.institution_name)

      super(statement: statement, ynab4_file: ynab4_file, transformers:
            transformers)
    end
  end
end
