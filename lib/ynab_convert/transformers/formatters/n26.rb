# frozen_string_literal: true

require 'ynab_convert/transformers/formatters/formatter'

module Formatters
  class N26 < Formatter
    # All amounts are always in EUR
    def memo(_row)
      'EUR'
    end
  end
end
