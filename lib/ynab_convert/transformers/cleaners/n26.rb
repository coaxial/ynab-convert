# frozen_string_literal: true

module Cleaners
  # Cleans N26 Statements
  class N26 < Cleaner
    def run(row)
      # No cleaning required
      row
    end
  end
end
