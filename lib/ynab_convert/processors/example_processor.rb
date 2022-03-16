# frozen_string_literal: true

require 'ynab_convert/documents'
require 'ynab_convert/transformers'
require 'ynab_convert/processors/processor'

module Processors
  # Example Processor
  class Example < Processor
    # @param filepath [String] path to the CSV file
    def initialize(filepath:)
      transformers = [
        Transformers::Formatters::Example.new
      ]
      statement = Documents::Statements::Example.new(filepath: filepath)
      ynab4_file = Documents::YNAB4Files::YNAB4File.new(
        format: :flows, institution_name: statement.institution_name
      )

      super(statement: statement, ynab4_file: ynab4_file, transformers:
            transformers)
    end
  end
end
