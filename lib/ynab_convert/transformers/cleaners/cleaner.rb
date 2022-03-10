# frozen_string_literal: true

module Cleaners
  # A Cleaner tidies up the Statement fields. For instance, it removes junk
  # from the transaction descriptions/payee name, combines several columns into
  # one to build the payee name, etc.
  # Because it is Statement specific, the `parse` method should be implemented
  # in the instance.
  class Cleaner
    # Cleans up a row
    # @param row [Array<String, Numeric, Date>] The row to parse
    # @return [void]
    def parse(_row)
      raise NotImplementedError, :parse
    end
  end
end
