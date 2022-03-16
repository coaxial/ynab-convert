# frozen_string_literal: true

require 'ynab_convert/transformers'

module Transformers
  module Formatters
    # Formats N26 statement values to YNAB4 value
    class N26 < Formatter
      def initialize
        super({ date: [0], payee: [1], amount: [5] })
      end

      # All amounts are always in EUR
      def memo(_row)
        'EUR'
      end
    end
  end
end
