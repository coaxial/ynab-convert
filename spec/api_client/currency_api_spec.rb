# frozen_string_literal: true

require 'ynab_convert/config.rb'
require 'ynab_convert/api_client/currency_api.rb'

RSpec.describe YnabConvert::APIClient::CurrencyApi do
  let(:client) { YnabConvert::APIClient::CurrencyApi.new }

  context 'with a valid date' do
    it 'gives the historical rates', :vcr do
      actual = client.historical(base_currency: :eur, date: '2022-03-07')

      expect(actual[:date]).to eq('2022-03-07')
      expect(actual[:eur][:ada]).to eq(1.328079)
    end
  end

  context 'with today\'s date' do
    it 'throws a meaningful error'
  end

  context 'with a date before 2020-11-22' do
    it 'throws a meaningful error'
  end
end
