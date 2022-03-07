# frozen_string_literal: true

module Processor
  # Processes CSV files from UBS Personal Banking Switzerland
  class UbsChequing < Processor::Base
    # @option options [String] :file Path to the CSV file to process
    def initialize(options)
      register_custom_converters
      @loader_options = {
        col_sep: ';',
        converters: %i[amounts transaction_dates],
        quote_char: nil,
        encoding: Encoding::UTF_8,
        headers: true
      }
      @institution_name = 'UBS (Chequing)'

      super(options)
    end

    protected

    def transformers(row)
      date = extract_transaction_date(row).strftime('%d/%m/%Y')
      payee = transaction_payee(row)
      unless row[headers[:debit]].nil?
        debit = format('%<amount>.2f', amount: row[headers[:debit]])
      end
      unless row[headers[:credit]].nil?
        credit = format('%<amount>.2f', amount: row[headers[:credit]])
      end

      converted_row = [
        date,
        payee,
        nil,
        debit,
        credit
      ]

      logger.debug "Converted row: #{converted_row}"
      converted_row
    end

    def extract_transaction_date(row)
      skip_row(row) if row[headers[:transaction_date]].nil?
      row[headers[:transaction_date]]
    end

    private

    def extract_header_names(row)
      headers[:transaction_date] ||= row.headers[9]
      headers[:payee_line_1] ||= row.headers[12]
      headers[:payee_line_2] ||= row.headers[13]
      headers[:payee_line_3] ||= row.headers[14]
      headers[:debit] ||= row.headers[18]
      headers[:credit] ||= row.headers[19]
    end

    def transaction_payee(row)
      raw_payee_line = [
        row[headers[:payee_line_2]],
        row[headers[:payee_line_3]]
      ]

      # Transaction description is spread over 3 columns.
      # There are two types of entries:
      # 1. only the first column contains data
      # 2. all three columns contain data, most of it junk
      #
      # Cleaning them up means dropping the first column if there is anything
      # in the other columns;
      # removing the CARD 00000000-0 0000 at the beginning of debit card
      # payment entries;
      # removing the rest of the junk appended after the worthwhile data (see
      # below for details on that)
      if row[headers[:payee_line_2]].nil?
        # Make it an Array, for consistency
        raw_payee_line = [row[headers[:payee_line_1]]]
      end

      concat_payee_line = raw_payee_line.join(' ')

      # Moreover, UBS thought wise to append a bunch of junk information after
      # the transaction details within the third description field. *Most* of
      # this junk starts after the meaningful data and starts with ", OF",
      # ", ON", ", ESR", ", QRR", two digits then five groups of five digits
      # then ", TN" so we discard it; YNAB4 being unable to automatically
      # categorize new transactions at the same store/payee because the payee
      # always looks different (thanks to the variable nature of the appended
      # junk).
      # See `spec/fixtures/ubs_chequing/statement.csv` L2 and L18--22

      # rubocop:disable Metrics/LineLength
      junk_desc_regex = /,? (O[FN]|ESR|QRR|\d{2} \d{5} \d{5} \d{5} \d{5} \d{5}, TN).*/
      # rubocop:enable Metrics/LineLength

      # Of course, it wouldn't be complete with more junk information at the
      # beginning of *some* lines (debit card payments)
      debit_card_junk_regex = /CARD \d{8}\-\d \d{4} /

      concat_payee_line.sub(junk_desc_regex, '').sub(debit_card_junk_regex, '')
    end

    def register_custom_converters
      CSV::Converters[:amounts] = lambda { |s|
        # Regex checks if string has only digits, apostrophes, and ends with a
        # dot and two digits
        amount_regex = /^[\d'?]+\.\d{2}$/

        if !s.nil? && s.match(amount_regex)
          amount = s.delete("'") .to_f
          logger.debug "Converted `#{s}' into amount `#{amount}'"
          return amount
        end

        logger.debug "Not an amount, not parsing `#{s.inspect}'"
        s
      }

      CSV::Converters[:transaction_dates] = lambda { |s|
        date_regex = /^\d{2}\.\d{2}\.\d{4}$/

        if !s.nil? && s.match(date_regex)
          parsed_date = Date.parse(s)
          logger.debug "Converted `#{s.inspect}' into date "\
            "`#{parsed_date}'"
          parsed_date
        else
          logger.debug "Not a date, not parsing #{s.inspect}"
          s
        end
      }
    end
  end
end
