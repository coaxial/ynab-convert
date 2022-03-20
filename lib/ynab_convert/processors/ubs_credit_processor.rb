# frozen_string_literal: true

module Processors
  # UBS Switzerland Credit Card accounts processor
  class UBSCredit < Processor
    def initialize(filepath:)
      statement = Documents::Statements::UBSCredit.new(filepath: filepath)
      ynab4_file_options = { institution_name: statement.institution_name }
      ynab4_file = Documents::YNAB4Files::YNAB4File.new(ynab4_file_options)
      transformers = [Transformers::Cleaners::UBSCredit.new,
                      Transformers::Formatters::UBSCredit.new]

      super(statement: statement, ynab4_file: ynab4_file, transformers:
            transformers)
    end
  end
end
