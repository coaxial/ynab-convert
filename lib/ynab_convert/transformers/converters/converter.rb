# frozen_string_literal: true

module Converters
  # Turns raw CSV cell contents into the appropriate Ruby primitives.
  # Base class for Converters
  class Converter
    # @param custom_converters [Hash<Symbol, CSV::FieldsConverter>] A Hash of
    #   converters
    # to run each field through
    def initialize(custom_converters: {})
      # Register converters
      custom_converters.each do |name, blk|
        CSV::Converters[name] = blk
      end
    end
  end
end
