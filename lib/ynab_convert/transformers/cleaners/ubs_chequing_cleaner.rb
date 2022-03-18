# frozen_string_literal: true

module Transformers
  module Cleaners
    # UBS Switzerland Chequing accounts cleaner
    class UBSChequing < Cleaner
      HEADERS = {
        date: 9,
        payee_line1: 12,
        payee_line2: 13,
        payee_line3: 14,
        outflow: 18,
        inflow: 19
      }.freeze

      def run(row)
        date = parse_transaction_date(row[HEADERS[:date]])
        payee = clean_payee_lines(row)
        outflow = parse_amount(row[HEADERS[:outflow]])
        inflow = parse_amount(row[HEADERS[:inflow]])

        cleaned_row = row.dup
        cleaned_row[HEADERS[:date]] = date
        # Put all the relevant payee data in the first line and empty the other
        # two lines
        cleaned_row[HEADERS[:payee_line1]] = payee
        cleaned_row[HEADERS[:payee_line2]] = ''
        cleaned_row[HEADERS[:payee_line3]] = ''
        cleaned_row[HEADERS[:outflow]] = outflow
        cleaned_row[HEADERS[:inflow]] = inflow

        cleaned_row
      end

      private

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

      def clean_payee_lines(row)
        # Some lines are just bogus without any payee info. These will get
        # weeded out down the line by the validators.
        return row if row[HEADERS[:payee_line1]].nil? ||
                      row[HEADERS[:payee_line1]].empty?

        # Transaction description is spread over 3 columns.
        # There are two types of entries:
        # 1. only the first column contains data
        # 2. all three columns contain data, most of it junk, with only cols 2
        #   and 3 having meaningful data
        # Cleaning them up means dropping the first column if there is anything
        # in the other columns;
        # Then removing the rest of the junk appended after the worthwhile data;
        # Finally removing the CARD 00000000-0 0000 at the beginning of debit
        # card payment entries
        raw_payee_line = [row[HEADERS[:payee_line2]],
                          row[HEADERS[:payee_line3]]].join(' ')
        if row[HEADERS[:payee_line2]].nil?
          raw_payee_line = row[HEADERS[:payee_line1]]
        end

        # UBS thought wise to append a bunch of junk information after the
        # transaction details within the third description field. *Most* of
        # this junk starts after the meaningful data and starts with ", OF", ",
        # ON", ", ESR", ", QRR", two digits then five groups of five digits
        # then ", TN" so we discard it; YNAB4 being unable to automatically
        # categorize new transactions at the same store/payee if the payee
        # always looks different (thanks to the variable nature of the appended
        # junk).

        # rubocop:disable Layout/LineLength
        junk_desc_regex = /,? (O[FN]|ESR|QRR|\d{2} \d{5} \d{5} \d{5} \d{5} \d{5}, TN).*/
        # rubocop:enable Layout/LineLength

        # Of course, it wouldn't be complete with more junk information at the
        # beginning of *some* lines (debit card payments) in the following
        # form: "CARD 00000000-0 0000"
        debit_card_junk_regex = /CARD \d{8}-\d \d{4} /

        raw_payee_line.sub(junk_desc_regex, '').sub(debit_card_junk_regex, '')
      end
    end
  end
end
