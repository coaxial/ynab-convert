# frozen_string_literal: true

require 'ynab_convert/transformers/enhancers/enhancer'
require 'ynab_convert/api_clients/currency_api'

module Transformers
  module Enhancers
    # Converts amounts from EUR to CHF
    class N26 < Enhancer
      def initialize
        @api_client = APIClients::CurrencyAPI.new
      end

      # @param row [CSV::Row] The YNAB4 formatted row to enhance
      # @return [CSV::Row] A YNAB4 formatted row with amounts converted
      # @note The currency is hardcoded to CHF for now
      # @note Takes a YNAB4 formatted CSV::Row, with the transaction's currency
      # in the Memo field
      def run(row)
        # Handle :flows and :amounts formats
        amount_index = 3
        # "".to_f => 0.0
        amount_index = 4 if row[3].to_f == 0.0
        amount = row[amount_index]

        # Transaction currency should be in the memo field
        base_currency = row[2].to_sym

        date = row[0]

        # TODO: Implement a config file for currencies
        converted_amount = convert_amount(amount: amount,
                                          base_currency: base_currency,
                                          target_currency: :chf,
                                          date: date)

        enhanced_row = row.dup
        enhanced_row[amount_index] = converted_amount
        # Remove currency in memo
        enhanced_row[2] = ''
        enhanced_row
      end

      private

      # @param base_currency [Symbol] The ISO symbol of the amount's
      #   currency (base currency)
      # @param target_currency [Symbol] The ISO symbol of the currency to
      #   convert the amount to (target currency)
      # @param date [Date] The date on which to fetch the rate for conversion
      # @return [Float] The conversion rate for amount_currency into CHF
      def get_rate_for_date(base_currency:, target_currency:, date:)
        rates = @api_client.historical(base_currency: base_currency, date: date)
        rates[target_currency]
      end

      # @param base_currency [Symbol] The ISO symbol of the amount's
      #   currency
      # @param target_currency [Symbol] The ISO symbol of the currency to
      #   convert the amount to (target currency)
      # @param amount [Numeric] The amount in amount_currency to convert
      # @param date [Date] The date on which to fetch the rate for conversion
      # @return [Numeric] The converted amount
      def convert_amount(amount:, base_currency:, target_currency:, date:)
        rate = get_rate_for_date(base_currency: base_currency,
                                 target_currency: target_currency,
                                 date: date)

        # format('%<converted>.2f', converted: amount * rate)
        (amount * rate).round(2)
      end
    end
  end
end
