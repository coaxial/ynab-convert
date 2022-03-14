# frozen_string_literal: true

require 'ynab_convert/transformers/formatters/formatter'

module Formatters
  # Formats N26 statement values to YNAB4 value
  class N26 < Formatter
    # All amounts are always in EUR
    def memo(_row)
      'EUR'
    end
  end
end
