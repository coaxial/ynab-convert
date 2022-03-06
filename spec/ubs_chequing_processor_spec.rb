# frozen_string_literal: true

RSpec.describe(Processor::UbsChequing) do
  fixture_path = 'fixtures/ubs_chequing/statement.csv'

  context('with any file') do
    before(:context) do
      @subject = Processor::UbsChequing.new(
        file: File.join(File.dirname(__FILE__), fixture_path)
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
      filename = File.join(File.dirname(__FILE__), fixture_path)
      @subject = Processor::UbsChequing.new(file: filename)
    end

    # it 'outputs valid YNAB4 CSV data', :writes_csv do
    it 'outputs valid YNAB4 CSV data' do
      @subject.to_ynab!
      actual = File.read(
        'statement_ubs_chequing_20191018-20191106_ynab4.csv'
      )
      expected = <<~ROWS
        "Date","Payee","Memo","Outflow","Inflow"
        "06/11/2019","Recouvrement VIS1W OBJECTION TO UBS WITHIN 30 DAYS, UBS SWITZERLAND AG, C/O UBS CARD CENTER, CREDIT CARD STATEMENT","","10959.40",""
        "04/11/2019","Ordre e-banking TRANSFER CH0123456789012345678, FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, E-Banking virement compte à compte","","21502.00",""
        "29/10/2019","Ordre e-banking PAYMENT FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, PAYMENT, E-Banking virement compte à compte","","1725.00",""
        "29/10/2019","Ordre e-banking PAYMENT FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, E-Banking virement compte à compte","","920.53",""
        "25/10/2019","Entrée salaire Entrée paiement SIC ","","","16399.80"
        "21/10/2019","Ordre e-banking A STORE 8001 ZURICH, E-Banking CHF intérieur","","175.40",""
        "18/10/2019","Virement WALTER WHITE BAHNHOFSTRASSE 1, 8001 ZURICH, SOME REFERENCE, SECOND LINE, Entrée paiement SIC","","","53512.00"
        "18/10/2019","Paiement carte de debit CARD 00000000-0 0000 Shop AG, 1234 St. Santis","","3010.66",""
        "18/10/2019","Ordre PayNet EBILL INVOICE SWISSCOM SCHWEIZ AG, 3050 BERN","","1620.00",""
        "18/10/2019","Ordre e-banking DO IT GARDEN, MIGROS-GENOSSENSCHAFT S-BUND","","199.10",""
        "18/10/2019","Ordre PayNet EBILL INVOICE ST.PLACE STADTWERKE, 6660 ST. PLACE","","283.00",""
      ROWS

      expect(actual).to eq(expected)
    end
  end
end
