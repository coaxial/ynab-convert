# frozen_string_literal: true

module Processors
  # UBS Switzerland Chequing accounts processor
  class UBSChequing < Processor
    # @param filepath [String] path to the CSV file
    def initialize(filepath:)
      transformers = [
        Transformers::Cleaners::UBSChequing.new,
        Transformers::Formatters::UBSChequing.new
      ]
      statement = Documents::Statements::UBSChequing.new(filepath: filepath)
      ynab4_file_options = { format: :flows,
                             institution_name: statement.institution_name }
      ynab4_file = Documents::YNAB4Files::YNAB4File.new(ynab4_file_options)

      super(statement: statement, ynab4_file: ynab4_file, transformers:
            transformers)
    end
  end
end
