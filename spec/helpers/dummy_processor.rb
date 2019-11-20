# frozen_string_literal: true

module Processor
  class Dummy < Processor::Base
    def initialize(options)
      @loader_options = {
        col_sep: ';',
        headers: true
      }
      @institution_name = 'Dummy Bank'

      super(options)
    end

    protected

    def converters(row)
      transaction_date = Date.strptime(row['transaction_date'], '%d.%m.%y')

      [transaction_date.strftime('%d/%m/%Y'),
       row['beneficiary'],
       '',
       row['debit'] || '',
       row['credit'] || '']
    end

    def extract_transaction_date(row)
      Date.strptime(row['transaction_date'], '%d.%m.%y')
    end
  end
end
