# frozen_string_literal: true

module Enhancers
  # An Enhancer parses YNAB4 rows (Date, Payee, Memo, Amount or Inflow and
  # Outflow) and augments the data therein.
  # A typical case would be converting from one currency to the user's YNAB
  # base currency when the Statement is in a different currency.
  class Enhancer
    def initialize; end

    # @param _row [CSV::Row] The row to enhance
    # @return [CSV::Row] The enhanced row
    def enhance(_row)
      raise NotImplementedError, :enhance
    end
  end
end
