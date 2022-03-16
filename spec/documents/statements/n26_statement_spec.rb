# frozen_string_literal: true

RSpec.describe Documents::Statements::N26 do
  statement = File.join(File.dirname(__dir__),
                        '..',
                        'fixtures/statements/n26_statement.csv')

  let(:subject) { Documents::Statements::N26.new(filepath: statement) }

  it 'inherits from Statement' do
    expect(subject).to be_kind_of(Documents::Statements::Statement)
  end
end
