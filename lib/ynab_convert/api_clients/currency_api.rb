# frozen_string_literal: true

require 'ynab_convert/api_clients/api_client'

module APIClients
  # Client for currency-api
  # (https://github.com/fawazahmed0/currency-api#readme)
  class CurrencyAPI < APIClient
    def initialize
      api_base_path = 'https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/'
      @available_date_range = {
        min: Date.parse('2020-11-22'),
        max: Date.today - 1 # yesterday
      }

      super(api_base_path: api_base_path)
    end

    def historical(base_currency:, date:)
      handle_date_out_of_bounds(date) if out_of_bounds?(date)
      currency = base_currency.downcase
      endpoint = "#{date}/currencies/#{currency}.min.json"
      rates = make_request(endpoint: endpoint)
      rates[currency]
    end

    private

    # The currency-api only has rates since 2020-11-22 and until yesterday
    # (the current day's rate are updated at 23:59 on that day). This method
    # ensures the requested date falls within the available range.
    # @param date [String] Date in YYYY-MM-DD format
    # @return [Boolean] Whether the date is out of bounds for this API
    def out_of_bounds?(date)
      parsed_date = Date.parse(date)

      parsed_date < @available_date_range[:min] ||
        parsed_date > @available_date_range[:max]
    end

    # @param date [String] Date in YYYY-MM-DD format
    # @return [Errno::EDOM] Raises an Errno::EDOM
    def handle_date_out_of_bounds(date)
      error_message = "#{date} is out of the currency-api available date "\
      "range (#{@available_date_range[:min]}–#{@available_date_range[:max]})"

      raise Errno::EDOM, error_message
    end
  end
end
