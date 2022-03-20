# frozen_string_literal: true

module Transformers
  module Cleaners
    # UBS Switzerland Credit Card accounts cleaner
    class UBSCredit < Cleaner
      HEADERS = {
        date: 3,
        payee: 4,
        outflow: 10,
        inflow: 11
      }.freeze

      def run(row)
        date = parse_transaction_date(row[HEADERS[:date]])
        outflow = parse_amount(row[HEADERS[:outflow]])
        inflow = parse_amount(row[HEADERS[:inflow]])

        cleaned_row = row.dup
        cleaned_row[HEADERS[:date]] = date
        cleaned_row[HEADERS[:outflow]] = outflow
        cleaned_row[HEADERS[:inflow]] = inflow

        cleaned_row
      end

      def parse_transaction_date(date)
        # Transaction dates are dd.mm.YYYY which Date#parse understands, but
        # the CSV::Converter[:date] doesn't recognize it as it's not looking
        # for dot separators.
        return Date.parse(date) unless date.is_a?(Date) || date.nil?

        date
      end

      def parse_amount(amount)
        unless amount.nil? || amount.is_a?(Numeric)
          return amount.delete("'").to_f
        end

        amount
      end
    end
  end
end
