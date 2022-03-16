# frozen_string_literal: true

require 'ynab_convert/documents/statements/statement'

RSpec.describe Documents::Statements::Example do
  statement = File.join(File.dirname(__dir__),
                        '..',
                        'fixtures/statements/example_statement.csv')

  let(:subject) { Documents::Statements::Example.new(filepath: statement) }

  it 'inherits from Statement' do
    expect(subject).to be_kind_of(Documents::Statements::Statement)
  end
end
