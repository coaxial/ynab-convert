# frozen_string_literal: true

require 'ynab_convert/api_client/currency_api.rb'

module YnabConvert
  # Converts between currencies for a given date.
  class CurrencyConverter
    # @param client [YnabConvert::APIClient::CurrencyAPI] API client override
    #   (typically used for testing with mocks/doubles).
    def initialize(client: YnabConvert::APIClient::CurrencyAPI.new)
      @client = client
    end

    # Convert amounts between currencies using historical rates.
    # @param from [Symbol] ISO name for base currency
    # @param to [Symbol] ISO name for target currency
    # @param date [String] The exchange rate's day to use for conversion
    # @param amount [Numeric] The amount to convert from base currency to
    #   target currency
    # @return [Numeric] The converted amount in target currency
    def exchange(from:, to:, date:, amount:)
      all_currencies = @client.historical(base_currency: from.downcase,
                                          date: date)
      rate = all_currencies[from.downcase][to.downcase]

      amount * rate
    end
  end
end
