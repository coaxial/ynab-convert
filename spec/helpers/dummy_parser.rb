# frozen_string_literal: true

module Parser
  class Dummy < Parser::Base
    def initialize(options)
      opts = options.merge(institution_name: 'Dummy Bank')
      super(opts)
    end

    def to_ynab
      converted_csv
      # options = { col_sep: ';',
      #             converters: %i[numeric date],
      #             headers: true }
      # options2 = {
      #   converters: %i[numeric date],
      #   force_quotes: true
      # }
      # headers = %w[Date Payee Memo Outflow Inflow]
      # CSV.generate(options2) do |csv|
      #   CSV.foreach(@file, options) do |row|
      #     puts '---'
      #     puts row.to_h
      #     puts row['transaction_date']
      #     puts '---'
      #     csv << [row['transaction_date'],
      #             row['beneficiary'],
      #             '',
      #             row['debit'] || '',
      #             row['credit'] || '']
      #   end
      # end
    end

    def to_ynab!
      super(to_ynab)
    end

    protected

    def original_csv(&block)
      options = { col_sep: ';',
                  converters: %i[numeric date],
                  headers: true }
      CSV.foreach(@file, options, &block)
    end

    def converted_csv
      data = []
      # YNAB4 columns are: Date, Payee, Memo, Outflow, Inflow
      original_csv do |row|
        data << [row['transaction_date'],
                 row['beneficiary'],
                 '',
                 row['debit'],
                 row['credit']]
      end
      data
    end
  end
end
