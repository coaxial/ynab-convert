# frozen_string_literal: true

RSpec.describe Transformers::Formatters::N26 do
  let(:statement) do
    options = { col_sep: ',', quote_char: '"', headers: true }
    CSV.read('spec/fixtures/statements/n26_statement.csv', options)
  end
  let(:n26_formatter) { described_class.new }
  let(:formatted) do
    [
      ['2022-01-20', 'Amel MaruMaru', 'EUR', '200000.0'],
      ['2022-02-11', 'Hallberg-Rassy', 'EUR', '-120000.0']
    ]
  end

  it 'inherits from Formatters::Formatter' do
    expect(n26_formatter).to be_kind_of(Transformers::Formatters::Formatter)
  end

  it 'formats rows' do
    actual = statement.reduce([]) { |acc, row| acc << n26_formatter.run(row) }

    expect(actual).to eq(formatted)
  end
end
