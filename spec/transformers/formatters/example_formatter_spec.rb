# frozen_string_literal: true

RSpec.describe Transformers::Formatters::Example do
  let(:statement) do
    options = { col_sep: ';', quote_char: nil, headers: true }
    CSV.read('spec/fixtures/statements/example_statement.csv', options)
  end
  let(:subject) { Transformers::Formatters::Example.new }

  it 'inherits from Formatter' do
    expect(subject).to be_kind_of(Transformers::Formatters::Formatter)
  end

  it 'formats rows' do
    actual = statement.reduce([]) { |acc, row| acc << subject.run(row) }
    expected = [
      ['2019-12-23', 'coaxial', '', '1000000.00', ''],
      ['2019-12-30', 'Santa', '', '50000.00', ''],
      ['2020-02-02', 'Someone Else', '', '45.00', '']
    ]

    expect(actual).to eq(expected)
  end
end
