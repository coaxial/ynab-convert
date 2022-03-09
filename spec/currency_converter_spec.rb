# frozen_string_literal: true

require 'ynab_convert/currency_converter.rb'

RSpec.describe YnabConvert::CurrencyConverter do
  let(:converter) { YnabConvert::CurrencyConverter.new }

  it 'converts currency', :vcr do
    actual = converter.exchange(
      from: :eur,
      to: :chf,
      date: '2022-01-01',
      amount: 1337.0 # EUR
    )
    expected = 1386.12138 # CHF

    expect(actual).to eq(expected)
  end

  it 'works with upper case currency names', :vcr do
    actual = converter.exchange(
      from: :EUR,
      to: :CHF,
      date: '2022-01-01',
      amount: 1337.0 # EUR
    )
    expected = 1386.12138 # CHF

    expect(actual).to eq(expected)
  end
end
