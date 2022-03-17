# frozen_string_literal: true

module Transformers
  module Formatters
    # UBS Switzerland Chequing accounts formatter
    class UBSChequing < Formatter
      def initialize
        super({ date: [9], payee: [12], outflow: [18], inflow: [19] })
      end
    end
  end
end
