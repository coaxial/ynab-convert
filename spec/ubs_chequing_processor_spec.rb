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
      @subject = Processor::UbsChequing.new(file: filename, language: :fr)
    end

    # it 'outputs valid YNAB4 CSV data', :writes_csv do
    fit 'outputs valid YNAB4 CSV data' do
      @subject.to_ynab!
      actual = File.read(
        'ubs_chequing_ubs_chequing_20191018-20191106_ynab4.csv'
      )
      expected = <<~ROWS
        "Date","Payee","Memo","Outflow","Inflow"
        "06/11/2019","Compte personnel UBS VIS1W OBJECTION TO UBS WITHIN 30 DAYS, UBS SWITZERLAND AG, C/O UBS CARD CENTER, CREDIT CARD STATEMENT, OF 15.11.2019, ACCOUNT NUMBER 0000 1234 5678 9012, LSV débit CHF","","10959.40",""
        "04/11/2019","Compte personnel UBS TRANSFER CH0123456789012345678, FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, E-Banking virement compte à compte","","21502.00",""
        "29/10/2019","Compte personnel UBS PAYMENT FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, PAYMENT, E-Banking virement compte à compte","","1725.00",""
        "29/10/2019","Compte personnel UBS PAYMENT FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, E-Banking virement compte à compte","","920.53",""
        "25/10/2019","Compte personnel UBS Entrée paiement SIC ","","","16399.80"
        "21/10/2019","Compte personnel UBS A STORE 8001 ZURICH, E-Banking CHF intérieur","","175.40",""
        "18/10/2019","Compte personnel UBS WALTER WHITE BAHNHOFSTRASSE 1, 8001 ZURICH, SOME REFERENCE, SECOND LINE, Entrée paiement SIC","","","53512.00"
      ROWS

      expect(actual).to eq(expected)
    end
  end
end
