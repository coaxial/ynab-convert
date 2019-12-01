# frozen_string_literal: true

module Processor
  # Processes CSV files from UBS Personal Banking Switzerland (French)
  class UbsChequing < Processor::Base
    # @option options [String] :file Path to the CSV file to process
    # @option options [Symbol] :language Language the file is in (headers are
    # not the same between French, German, and Italian). Possible values:
    # `:fr` (default), `:de`, `:it`, although only `:fr` is implemented at the
    # moment.
    def initialize(options)
      register_custom_converters
      # Set the default language, Processor::Base will overwrite it if present
      # in options
      @language = :fr
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

    # rubocop:disable Metrics/AbcSize
    # TODO: Fix AbcSize
    def converters(row)
      converted_row = [
        extract_transaction_date(row).strftime('%d/%m/%Y'),
        row[header_names[:payee]],
        '',
        row[header_names[:debit]] || '',
        row[header_names[:credit]] || ''
      ]
      logger.debug "Converted row: #{converted_row}"
      skip_row(row) if inflow_or_outflow_missing?(converted_row)
      converted_row
    end
    # rubocop:enable Metrics/AbcSize

    def extract_transaction_date(row)
      skip_row(row) if missing_transaction_date?(row)
      row[header_names[:transaction_date]]
    end

    private

    def register_custom_converters
      CSV::Converters[:amounts] = lambda { |s|
        # Regex checks if string has only digits, apostrophes, and ends with a
        # dot and two digits
        return s.delete("'") if !s.nil? && /[\d'?]+(\.\d{2})/.match(s)

        s
      }
      CSV::Converters[:transaction_dates] = lambda { |s|
        if !s.nil? && /\d{2}\.\d{2}\.\d{4}/.match(s)
          return Date.strptime(s, '%d.%m.%Y')
        end

        s
      }
    end

    def missing_transaction_date?(row)
      # If It's missing a transaction date, it's most likely invalid
      row[header_names[:transaction_date]].nil?
    end

    def inflow_or_outflow_missing?(row)
      inflow_index = 3
      outflow_index = 4
      # If there is neither inflow and outflow values, or their value is 0,
      # then the row is not valid to YNAB4
      (row[inflow_index].empty? || row[inflow_index] == '0.00') &&
        (row[outflow_index].empty? || row[outflow_index] == '0.00')
    end

    # The headers in the different languages that UBS produces them in
    def header_names
      case @language
      when :fr
        { transaction_date: 'Date de transaction', payee: 'Description 2',
          debit: 'Débit', credit: 'Crédit' }
      else
        raise YnabConvert::Error, "Language `#{@language.inspect}' missing in "\
          'processor'
      end
    end
  end
end
