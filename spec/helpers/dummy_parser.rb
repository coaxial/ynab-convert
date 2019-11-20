# frozen_string_literal: true

module Parser
  class Dummy < Parser::Base
    def initialize(options)
      opts = options.merge(institution_name: 'Dummy Bank')
      super(opts)
    end

    def to_ynab
      open_and_convert
    end

    def to_ynab!
      super(to_ynab)
    end

    protected

    def open_and_convert
      ynab_headers = %w[Date Payee Memo Outflow Inflow]
      csv_loading_options = { col_sep: ';',
                              headers: true }
      csv_converting_options = {
        converters: %i[numeric date],
        force_quotes: true,
        write_headers: true,
        headers: ynab_headers
      }

      CSV.generate(csv_converting_options) do |csv|
        CSV.foreach(@file, csv_loading_options) do |row|
          transaction_date = Date.strptime(row['transaction_date'], '%d.%m.%y')

          csv << [transaction_date.strftime('%d/%m/%Y'),
                  row['beneficiary'],
                  '',
                  row['debit'] || '',
                  row['credit'] || '']
        end
      end
    end
  end
end
