# frozen_string_literal: true

module Transformers
  module Cleaners
    # Wise card accounts cleaner
    class Wise < Cleaner
      def run(row)
        cleaned_row = row.dup
        date_index = 1
        cleaned_row[date_index] = Date.parse(cleaned_row[date_index])

        cleaned_row
      end
    end
  end
end
