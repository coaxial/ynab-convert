# frozen_string_literal: true

module Transformers
  module Formatters
    # Wise card accounts formatter
    class Wise < Formatter
      def initialize
        super({ date: [1], payee: [13], amount: [2] })
      end

      def memo(row)
        # Description goes in Memo because we'll need to extract the original
        # amount from it in the enhancer.
        description = row[4]
        amount_currency = row[3]
        original_amount = description.scan(/\d+\.\d{2}\s\w{3}/).first

        memo = amount_currency
        # Topups don't have an original amount
        memo = "#{memo},#{original_amount}" unless original_amount.nil?

        memo
      end
    end
  end
end
