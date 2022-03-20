# frozen_string_literal: true

module Transformers
  module Cleaners
    # Wise card accounts cleaner
    class Wise < Cleaner
      def run(row)
        date_index = 1
        payee_index = 13
        cleaned_row = row.dup
        date = parse_date(cleaned_row[date_index])
        payee = clean_payee(cleaned_row[payee_index])

        cleaned_row[date_index] = date
        cleaned_row[payee_index] = payee

        cleaned_row
      end

      # turn String "dd-mm-YYYY" into a Date since the
      # CSV::Transformers[:date] doesn't recognize the dd-mm-YYYY format
      # @param date [String] the date string to parse (format "dd-mm-YYYY")
      # @return Date the parsed date string
      def parse_date(date)
        Date.parse(date)
      end

      # The payee data can include some junk (mostly for PayPal/Ebay
      # transactions)
      # @param payee [String] the payee string to clean
      # @return String the payee string without the junk
      def clean_payee(payee)
        return payee if payee.nil?

        payee.gsub(/O\*\d{2}-\d{5}-\d{5}\s/, '')
      end
    end
  end
end
