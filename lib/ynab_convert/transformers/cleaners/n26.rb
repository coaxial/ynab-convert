# frozen_string_literal: true

module Cleaners
  class N26 < Cleaner
    def parse(row)
      # No cleaning required
      row
    end
  end
end
