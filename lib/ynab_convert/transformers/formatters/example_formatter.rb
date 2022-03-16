# frozen_string_literal: true

module Transformers
  module Formatters
    # Example Formatter
    class Example < Formatter
      def initialize
        super({ date: [0], payee: [2], outflow: [3], inflow: [4] })
      end
    end
  end
end
