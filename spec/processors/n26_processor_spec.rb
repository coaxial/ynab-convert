# frozen_string_literal: true

RSpec.describe Processors::N26, :vcr do
  let(:fixture_path) do
    File.join(File.dirname(__dir__),
              'fixtures/statements/n26_statement.csv')
  end
  let(:processor) { described_class.new(filepath: fixture_path) }
  let(:processed) do
    <<~CSV
      "Date","Payee","Memo","Amount"
      "2022-01-20","Amel MaruMaru","Original amount: 200000.00 EUR","207741.8"
      "2022-02-11","Hallberg-Rassy","Original amount: -120000.00 EUR","-126671.04"
    CSV
  end

  before { processor.to_ynab! }

  it 'instantiates' do
    expect(processor).to be_kind_of(Processors::Processor)
  end

  it 'converts the statement' do
    actual = File.read(File.join(File.dirname(__dir__), '..',
                                 'n26_20220120-20220211_ynab4.csv'))

    expect(actual).to eq(processed)
  end
end
