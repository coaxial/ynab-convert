# frozen_string_literal: true

module Processor
  # Processes CSV files from UBS Credit Cards Switzerland (French)
  class UbsCredit < Processor::Base
    # @option options [String] :file Path to the CSV file to process
    def initialize(options)
      register_custom_converters
      @loader_options = {
        col_sep: ';',
        converters: %i[amounts transaction_dates],
        quote_char: nil,
        encoding: "#{Encoding::ISO_8859_1}:#{Encoding::UTF_8}",
        headers: true,
        # CSV FTW, the first line in these files is not the headers but the
        # separator specification
        skip_lines: 'sep=;'
      }
      @institution_name = 'UBS (Credit cards)'

      super(options)
    end

    protected

    def transformers(row)
      unless row[headers[:transaction_date]].nil?
        date = row[headers[:transaction_date]].strftime('%d/%m/%Y')
      end
      payee = row[headers[:payee]]
      unless row[headers[:debit]].nil?
        debit = format('%<amount>.2f', amount: row[headers[:debit]])
      end
      unless row[headers[:credit]].nil?
        credit = format('%<amount>.2f', amount: row[headers[:credit]])
      end

      converted_row = [date, payee, nil, debit, credit]
      logger.debug "Converted row: #{converted_row}"
      converted_row
    end

    private

    def extract_header_names(row)
      headers[:transaction_date] ||= row.headers[3]
      headers[:payee] ||= row.headers[4]
      headers[:debit] ||= row.headers[10]
      headers[:credit] ||= row.headers[11]
    end

    def register_custom_converters
      CSV::Converters[:amounts] = lambda { |s|
        # Regex checks if string has only digits, apostrophes, and ends with a
        # dot and two digits
        amount_regex = /^[\d'?]+(\.\d{2})$/

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
