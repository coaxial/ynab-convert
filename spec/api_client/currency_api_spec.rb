# frozen_string_literal: true

require 'ynab_convert/config.rb'
require 'ynab_convert/api_client/currency_api.rb'

RSpec.describe YnabConvert::APIClient::CurrencyAPI do
  let(:client) { YnabConvert::APIClient::CurrencyAPI.new }

  context 'with a valid date' do
    it 'gives the historical rates', :vcr do
      actual = client.historical(base_currency: :eur, date: '2022-03-07')

      expect(actual[:date]).to eq('2022-03-07')
      expect(actual[:eur][:ada]).to eq(1.328079)
    end
  end

  context 'with today\'s date' do
    it 'throws a meaningful error', :vcr do
      actual = lambda {
        client.historical(base_currency: :eur, date: '2022-03-09')
      }

      expect(&actual).to raise_error(Errno::EDOM, /.* out of .* range.*/)
    end
  end

  context 'with a date before 2020-11-22' do
    it 'throws a meaningful error', :vcr do
      actual = lambda {
        client.historical(base_currency: :eur, date: '1986-07-25')
      }

      expect(&actual).to raise_error(Errno::EDOM, /.* out of .* range.*/)
    end
  end
end
