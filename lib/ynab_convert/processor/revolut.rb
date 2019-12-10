# frozen_string_literal: true

require 'i18n'

module Processor
  # Processes CSV files from Revolut
  class Revolut < Processor::Base
    # @option options [String] :file Path to the CSV file to process
    def initialize(options)
      register_custom_converters
      # Set the default language, Processor::Base will overwrite it if present
      # in options
      @loader_options = {
        col_sep: ';',
        converters: %i[amounts transaction_dates],
        quote_char: nil,
        encoding: Encoding::UTF_8,
        headers: true
      }
      @institution_name = 'Revolut'

      super(options)
    end

    protected

    # TODO: Fix AbcSize
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def converters(row)
      date = extract_transaction_date(row).strftime('%d/%m/%Y')
      payee = row[headers[:payee]]
      unless row[headers[:debit]].nil?
        debit = format('%<amount>.2f', amount: row[headers[:debit]])
      end
      unless row[headers[:credit]].nil?
        credit = format('%<amount>.2f', amount: row[headers[:credit]])
      end

      ynab_row = [
        date,
        payee,
        nil,
        debit,
        credit
      ]

      logger.debug "Converted row: #{ynab_row}"
      ynab_row
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def extract_header_names(row)
      @headers[:transaction_date] ||= row.headers[0]
      @headers[:payee] ||= row.headers[1]
      @headers[:debit] ||= row.headers[2]
      @headers[:credit] ||= row.headers[3]
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def register_custom_converters
      CSV::Converters[:amounts] = lambda { |s|
        # Yes, amount come with a non breaking trailing space... Which is
        # matched with \p{Zs} (c.f.
        # https://ruby-doc.org/core-2.6/Regexp.html#class-Regexp-label-Character+Properties)
        # Also, thousands separators can be non breaking spaces.
        amount_regex = /^[\d'\.,\p{Zs}]+[\.,]\d{2}\p{Zs}$/
        # narrow_nbsp = "\0xE2\0x80\0xAF"
        narrow_nbsp = "\u{202F}"
        readability_separators = "',. #{narrow_nbsp}"

        if !s.nil? && s.match(amount_regex)
          # This is a bit hacky because we don't have the luxury of Rails' i18n
          # helpers. If we have an amount, strip all the separators in it, turn
          # it to a float, and divide by 100 to get the right amount back
          amount = s.delete(readability_separators).to_f / 100
          logger.debug "Converted `#{s}' into amount `#{amount}'"
          return amount
        end

        logger.debug "Not an amount, not parsing `#{s.inspect}'"
        s
      }

      # rubocop:disable Style/AsciiComments
      CSV::Converters[:transaction_dates] = lambda { |s|
        begin
          # Date.parse('6 decembre') is fine, but Date.parse('6 décembre') is
          # an invalid date so we must remove diacritics before trying to parse
          I18n.available_locales = [:en]
          transliterated_s = I18n.transliterate s
          logger.debug "Converted `#{s.inspect}' into date "\
            "`#{Date.parse(transliterated_s)}'"
          Date.parse(transliterated_s)
        rescue StandardError
          logger.debug "Not a date, not parsing #{s.inspect}"
          s
        end
      }
      # rubocop:enable Style/AsciiComments
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def missing_transaction_date?(row)
      # If It's missing a transaction date, it's most likely invalid
      row[headers[:transaction_date]].nil?
    end
  end
end
