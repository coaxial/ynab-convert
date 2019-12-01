# frozen_string_literal: true

RSpec.describe(Processor::UbsChequing) do
  context('with any file') do
    before(:context) do
      @subject = Processor::UbsChequing.new(
        file: File.join(File.dirname(__FILE__), 'fixtures/ubs_chequing.csv')
      )
    end

    it 'instantiates' do
      expect(@subject).to be_an_instance_of(Processor::UbsChequing)
    end

    it 'inherits from Processor::Base' do
      expect(@subject).to be_kind_of(Processor::Base)
    end
  end

  context 'with a valid CSV file' do
    before(:context) do
      filename = File.join(File.dirname(__FILE__), 'fixtures/ubs_chequing.csv')
      @subject = Processor::UbsChequing.new(file: filename)
    end

    # it 'outputs valid YNAB4 CSV data', :writes_csv do
    it 'outputs valid YNAB4 CSV data' do
      @subject.to_ynab!
      actual = File.read(
        'ubs_chequing_ubs_chequing_20191018-20191104_ynab4.csv'
      )
      expected = <<~ROWS
        "Date","Payee","Memo","Outflow","Inflow"
        "04/11/2019","TRANSFER","","21502.00",""
        "29/10/2019","PAYMENT","","1725.00",""
        "29/10/2019","PAYMENT","","920.53",""
        "25/10/2019","Entrée paiement SIC","","","16399.80"
        "21/10/2019","A STORE","","175.40",""
        "18/10/2019","WALTER WHITE","","","53512.00"
      ROWS

      expect(actual).to eq(expected)
    end
  end
end
