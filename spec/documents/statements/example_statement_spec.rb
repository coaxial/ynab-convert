# frozen_string_literal: true

RSpec.describe Documents::Statements::Example do
  statement = File.join(File.dirname(__dir__),
                        '..',
                        'fixtures/statements/example_statement.csv')

  let(:example_statement) { described_class.new(filepath: statement) }

  it 'inherits from Statement' do
    expect(example_statement).to be_kind_of(Documents::Statements::Statement)
  end
end
