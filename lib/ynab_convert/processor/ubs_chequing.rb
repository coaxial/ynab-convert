# frozen_string_literal: true

module Processor
  # Processes CSV files from UBS Personal Banking Switzerland (French)
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

    def converters(row)
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
      # Transaction description is spread over 3 columns
      [
        row[headers[:payee_line_1]],
        row[headers[:payee_line_2]],
        row[headers[:payee_line_3]]
      ].join(' ')
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
