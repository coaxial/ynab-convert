# frozen_string_literal: true

RSpec.describe Transformers::Formatters::Example do
  let(:statement) do
    options = { col_sep: ';', quote_char: nil, headers: true }
    CSV.read('spec/fixtures/statements/example_statement.csv', options)
  end
  let(:formatter) { described_class.new }
  let(:formatted) do
    [
      ['2019-12-23', 'coaxial', '', '1000000.00', ''],
      ['2019-12-30', 'Santa', '', '50000.00', ''],
      ['2020-02-02', 'Someone Else', '', '45.00', '']
    ]
  end

  it 'inherits from Formatter' do
    expect(formatter).to be_kind_of(Transformers::Formatters::Formatter)
  end

  it 'formats rows' do
    actual = statement.reduce([]) { |acc, row| acc << formatter.run(row) }

    expect(actual).to eq(formatted)
  end
end
