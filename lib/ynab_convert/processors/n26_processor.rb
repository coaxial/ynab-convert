# frozen_string_literal: true

require 'ynab_convert/documents'
require 'ynab_convert/transformers'
require 'ynab_convert/processors/processor'

module Processors
  # Processor for N26 statements
  class N26 < Processor
    # @param filepath [String] path to the CSV file
    def initialize(filepath:)
      transformers = [
        Transformers::Cleaners::N26.new,
        Transformers::Formatters::N26.new,
        Transformers::Enhancers::N26.new
      ]
      statement = Documents::Statements::N26.new(filepath: filepath)
      ynab4_file = Documents::YNAB4Files::YNAB4File.new(format: :amounts,
                                                        institution_name:
                                             statement.institution_name)

      super(statement: statement, ynab4_file: ynab4_file, transformers:
            transformers)
    end
  end
end
