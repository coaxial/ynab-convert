# frozen_string_literal: true

require 'ynab_convert/transformers/formatters/n26'

RSpec.describe Formatters::N26 do
  let(:statement) do
    options = { col_sep: ',', quote_char: '"', headers: true }
    CSV.read('spec/fixtures/documents/statements/n26/n26.csv', options)
  end
  let(:subject) { Formatters::N26.new(date: [0], payee: [1], amount: [5]) }

  it 'inherits from Formatters::Formatter' do
    expect(subject).to be_kind_of(Formatters::Formatter)
  end

  it 'formats rows' do
    actual = statement.reduce([]) { |acc, row| acc << subject.format(row) }

    expected = [
      ['2022-01-20', 'Amel MaruMaru', 'EUR', '200000.0'],
      ['2022-02-11', 'Hallberg-Rassy', 'EUR', '-120000.0']
    ]

    expect(actual).to eq(expected)
  end
end
