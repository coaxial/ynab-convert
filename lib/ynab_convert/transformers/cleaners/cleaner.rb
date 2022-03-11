# frozen_string_literal: true

module Cleaners
  # A Cleaner tidies up the Statement fields. For instance, it removes junk
  # from the transaction descriptions/payee name, combines several columns into
  # one to build the payee name, etc.
  # Because it is Statement specific, the `parse` method should be implemented
  # in the instance.
  class Cleaner
    # Cleans up a row
    # @param row [CSV::Row] The row to parse in YNAB4 format
    # @return [CSV::Row] The cleaned up row in YNAB4 format
    def parse(_row)
      raise NotImplementedError, :parse
    end
  end
end
