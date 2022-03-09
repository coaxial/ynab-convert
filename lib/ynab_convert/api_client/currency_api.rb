# frozen_string_literal: true

require 'net/http'
require 'uri'

require 'ynab_convert/config.rb'

module YnabConvert
  # All API clients
  module APIClient
    # Client for currency-api
    # (https://github.com/fawazahmed0/currency-api#readme)
    class CurrencyApi
      def initialize
        @api_base_path = 'https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/'
        @available_date_range = {
          min: Date.parse('2020-11-22'),
          max: Date.today - 1 # yesterday
        }
      end

      # @option base_currency [Symbol] ISO base currency (case insensitive)
      # @option date [String] Day on which to retrieve rates, formatted as
      #   YYYY-MM-DD
      def historical(base_currency:, date:)
        handle_date_out_of_bounds(date) if out_of_bounds?(date)
        endpoint = "#{date}/currencies/#{base_currency}.min.json"
        make_request(endpoint: endpoint)
      end

      private

      def out_of_bounds?(date)
        parsed_date = Date.parse(date)

        parsed_date < @available_date_range[:min] ||
          parsed_date > @available_date_range[:max]
      end

      def handle_date_out_of_bounds(date)
        error_message = "#{date} is out of the currency-api available date "\
        "range (#{@available_date_range[:min]}–#{@available_date_range[:max]})"

        raise Errno::EDOM, error_message
      end

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
