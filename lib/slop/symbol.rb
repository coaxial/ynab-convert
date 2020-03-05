# frozen_string_literal: true

module Slop
  # Add an option to convert a string to a symbol
  class SymbolOption < Option
    def call(value)
      return value.to_sym unless value.empty?

      value
    end
  end
end
