# frozen_string_literal: true

module Transformers
  module Formatters
    # UBS Switzerland Credit Card accounts formatter
    class UBSCredit < Formatter
      def initialize
        super({ date: [3], payee: [4], outflow: [10], inflow: [11] })
      end
    end
  end
end
