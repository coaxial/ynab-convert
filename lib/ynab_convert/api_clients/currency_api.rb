# frozen_string_literal: true

require 'ynab_convert/api_clients/api_client'

module APIClients
  # Client for currency-api
  # (https://github.com/fawazahmed0/currency-api#readme)
  class CurrencyAPI < APIClient
    # The days that are missing from the API's otherwise normally available
    # range
    MISSING_DAYS = { '2021-09-14' => true }.freeze

    def initialize
      api_base_path = 'https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/'
      @available_date_range = {
        min: Date.parse('2020-11-22'),
        max: Date.today - 1 # yesterday
      }

      super(api_base_path: api_base_path)
    end

    # @param base_currency [Symbol] ISO symbol for base currency
    # @param date [Date, String] The date on which to get the rates for
    # @return [Hash<Symbol, Numeric>] The rates for that day in base_currency
    def historical(base_currency:, date:)
      parsed_date = date.is_a?(Date) ? date : Date.parse(date)
      handle_date_out_of_bounds(parsed_date) if out_of_bounds?(parsed_date)
      # Some days are missing from the API, use the previous day's rate if
      # a missing day is requested
      parsed_date -= 1 if missing_day?(date)
      currency = base_currency.downcase
      endpoint = "#{parsed_date}/currencies/#{currency}.min.json"
      rates = make_request(endpoint: endpoint)
      rates[currency]
    end

    private

    # The currency-api only has rates since 2020-11-22 and until yesterday
    # (the current day's rate are updated at 23:59 on that day). This method
    # ensures the requested date falls within the available range.
    # @param date [Date] The date to check
    # @return [Boolean] Whether the date is out of bounds for this API
    def out_of_bounds?(date)
      date < @available_date_range[:min] || date > @available_date_range[:max]
    end

    # @param date [Date] The date to show in the error message
    def handle_date_out_of_bounds(date)
      error_message = "#{date} is out of the currency-api available date "\
      "range (#{@available_date_range[:min]}–#{@available_date_range[:max]})"

      raise Errno::EDOM, error_message
    end

    # Indicates whether a date is missing from the API's normally available
    # date range
    # @param date [Date] the date to check
    # @return [Boolean] whether the date is unavailable in the API
    def missing_day?(date)
      MISSING_DAYS.key?(date.to_s)
    end
  end
end
