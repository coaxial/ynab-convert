# frozen_string_literal: true

require 'net/http'
require 'uri'

require 'ynab_convert/config.rb'

module YnabConvert
  # All API clients
  module APIClient
    # Client for currency-api
    # (https://github.com/fawazahmed0/currency-api#readme)
    class CurrencyAPI
      def initialize
        @api_base_path = 'https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/'
        @available_date_range = {
          min: Date.parse('2020-11-22'),
          max: Date.today - 1 # yesterday
        }
      end

      # Fetches historical exchange rate for base_currency on date.
      # @param base_currency [Symbol] ISO base currency (case insensitive)
      # @param date [String] Day on which to retrieve rates, formatted as
      #   YYYY-MM-DD
      # @return [Hash] Exchanges rates for base_currency on date
      def historical(base_currency:, date:)
        handle_date_out_of_bounds(date) if out_of_bounds?(date)
        endpoint = "#{date}/currencies/#{base_currency}.min.json"
        make_request(endpoint: endpoint)
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

      # @param [String] The endpoint to query, without a leading `/`
      # @return [Hash] Exchanges rates for base_currency on date
      def make_request(endpoint:)
        uri = URI(URI.join(@api_base_path, endpoint))

        response = Net::HTTP.get_response(uri)

        unless response.is_a?(Net::HTTPSuccess)
          raise YnabConvert::Error, 'error fetching exchange rates from '\
          'currency-api'
        end

        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
