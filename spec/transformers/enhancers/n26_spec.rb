# frozen_string_literal: true

require 'ynab_convert/transformers/enhancers/n26'

RSpec.describe Transformers::Enhancers::N26 do
  let(:subject) { Transformers::Enhancers::N26.new }

  it 'inherits from Enhancers::Enhancer' do
    expect(subject).to be_kind_of(Transformers::Enhancers::Enhancer)
  end

  context 'with a CSV::Row' do
    let(:ynab_csv) do
      csv = <<~CSV
        Date,Payee,Memo,Amount
        "2022-03-10","Test Payee","EUR","13.37"
        "2022-03-10","Test Credit","EUR","6.66"
      CSV
      options = { col_sep: ',', quote_char: '"', headers: true, converters:
                  %i[numeric] }
      CSV.parse(csv, options)
    end

    it 'converts currency', :vcr do
      actual = ynab_csv.reduce([]) do |acc, row|
        acc << subject.run(row).to_h
      end
      expected = [
        { 'Date' => '2022-03-10', 'Payee' => 'Test Payee', 'Memo' => '',
          'Amount' => '13.71' },
        { 'Date' => '2022-03-10', 'Payee' => 'Test Credit', 'Memo' => '',
          'Amount' => '6.83' }
      ]

      expect(actual).to eq(expected)
    end
  end
end
