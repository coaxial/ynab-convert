# frozen_string_literal: true

module Processors
  # Wise card accounts processor
  class Wise < Processor
    def initialize(filepath:)
      statement = Documents::Statements::Wise.new(filepath: filepath)
      ynab4_file = Documents::YNAB4Files::YNAB4File.new(
        institution_name: statement.institution_name, format: :amounts
      )
      transformers = [Transformers::Cleaners::Wise.new,
                      Transformers::Formatters::Wise.new,
                      Transformers::Enhancers::Wise.new]

      super(statement: statement, ynab4_file: ynab4_file, transformers:
transformers)
    end
  end
end
