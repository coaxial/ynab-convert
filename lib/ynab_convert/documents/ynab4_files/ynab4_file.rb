# frozen_string_literal: true

module Documents
  module YNAB4Files
    # Represents the YNAB4 formatted CSV data for importing into YNAB4
    class YNAB4File
      attr_reader :csv_export_options

      def initialize(format: :flows, institution_name:)
        @format = format
        @institution_name = institution_name
        @csv_export_options = {
          converters: %i[numeric date],
          force_quotes: true,
          write_headers: true,
          headers: headers
        }
      end

      def update_dates(row)
        date_index = 0
        transaction_date = row[date_index]
        unless transaction_date.is_a?(Date)
          transaction_date = Date.parse(transaction_date)
        end

        update_start_date(transaction_date)
        update_end_date(transaction_date)
      end

      def filename
        from_date = @start_date.strftime('%Y%m%d')
        to_date = @end_date.strftime('%Y%m%d')

        "#{@institution_name.snake_case}_#{from_date}-#{to_date}_ynab4.csv"
      end

      private

      def update_start_date(date)
        @start_date = date if @start_date.nil? || date < @start_date
      end

      def update_end_date(date)
        @end_date = date if @end_date.nil? || date > @end_date
      end

      def headers
        base_headers = %w[Date Payee Memo]
        extra_headers = %w[Outflow Inflow]

        extra_headers = %w[Amount] if @format == :amounts

        base_headers.concat(extra_headers)
      end
    end
  end
end
