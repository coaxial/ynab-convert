# frozen_string_literal: true

module Transformers
  module Enhancers
    # Wise card accounts enhancer
    class Wise < Enhancer
      def initialize
        @api_client = APIClients::CurrencyAPI.new
        super()
      end

      def run(ynab_row)
        indices = {
          date: 1,
          amount: 3,
          memo: 2
        }

        amount = ynab_row[indices[:amount]]
        date = ynab_row[indices[:date]]
        metadata = deserialize_metadata(ynab_row[indices[:memo]])

        converted_amount = convert_amount(amount: amount,
                                          base_currency:
                                          metadata[:amount_currency],
                                          target_currency: :chf, date: date)

        enhanced_row = ynab_row.dup
        enhanced_row[indices[:amount]] = converted_amount
        # Put original amount and currency in Memo
        enhanced_row[indices[:memo]] = "Original amount:
        #{metadata[:original_amount]}"

        enhanced_row
      end

      private

      # @param memo [String] string to deserialize (format is
      #   `<amount_currency>,<original_amount>`, as formatted by the
      #   wise_formatter.rb)
      def deserialize_metadata(memo)
        # metadata is `<amount_currency>,<original_amount>`
        split = memo.split(',')

        { amount_currency: split[0], original_amount: split[1] }
      end

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
