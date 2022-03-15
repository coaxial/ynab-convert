# frozen_string_literal: true

require 'ynab_convert/api_clients/currency_api'

RSpec.describe APIClients::CurrencyAPI, :vcr do
  let(:subject) { APIClients::CurrencyAPI.new }

  it 'inherits from APIClient' do
    expect(subject).to be_kind_of(APIClients::APIClient)
  end

  context 'with a valid date' do
    it 'fetches the rate' do
      actual = subject.historical(base_currency: :eur, date: '2022-03-10')

      expect(actual[:chf]).to eq(1.025742)
    end

    context 'with base_currency in upper case' do
      it 'fetches the rate' do
        actual = subject.historical(base_currency: :EUR, date: '2022-03-10')

        expect(actual[:chf]).to eq(1.025742)
      end
    end
  end

  context "with today's date" do
    let(:today) { Date.parse('2022-03-14') }

    before(:example) { Timecop.freeze(today) }

    it 'errors' do
      actual = lambda {
        subject.historical(base_currency: :eur, date: today.to_s)
      }

      expect(&actual).to raise_error(Errno::EDOM, /.* out of .* range.*/)
    end

    context 'with a date before 2020-11-22' do
      it 'errors' do
        actual = lambda {
          subject.historical(base_currency: :eur, date:
                                '1986-07-25')
        }

        expect(&actual).to raise_error(Errno::EDOM, /.* out of .* range.*/)
      end
    end
  end
end
