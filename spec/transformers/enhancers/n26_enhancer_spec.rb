# frozen_string_literal: true

RSpec.describe Transformers::Enhancers::N26 do
  let(:enhancer) { described_class.new }

  it 'inherits from Enhancers::Enhancer' do
    expect(enhancer).to be_kind_of(Transformers::Enhancers::Enhancer)
  end

  context 'with a CSV::Row' do
    let(:ynab_csv) do
      csv = <<~CSV
        Date,Payee,Memo,Amount
        "2022-03-10","Test Payee","EUR","13.37"
        "2022-03-10","Test Credit","EUR","66.60"
      CSV
      options = { col_sep: ',', quote_char: '"', headers: true, converters:
                  %i[numeric] }
      CSV.parse(csv, options)
    end
    let(:enhanced) do
      [
        { 'Date' => '2022-03-10', 'Payee' => 'Test Payee',
          'Memo' => 'Original amount: 13.37 EUR', 'Amount' => 13.71 },
        { 'Date' => '2022-03-10', 'Payee' => 'Test Credit',
          'Memo' => 'Original amount: 66.60 EUR', 'Amount' => 68.31 }
      ]
    end

    it 'converts currency', :vcr do
      actual = ynab_csv.reduce([]) do |acc, row|
        acc << enhancer.run(row).to_h
      end

      expect(actual).to eq(enhanced)
    end
  end
end
