# frozen_string_literal: true

RSpec.describe Processors::UBSChequing, :vcr do
  let(:fixture_path) do
    File.join(File.dirname(__dir__),
              'fixtures/statements/ubs_chequing_fixture.csv')
  end
  let(:processor) { described_class.new(filepath: fixture_path) }
  let(:processed) do
    <<~CSV
      "Date","Payee","Memo","Outflow","Inflow"
      "2019-11-06","VIS1W OBJECTION TO UBS WITHIN 30 DAYS, UBS SWITZERLAND AG, C/O UBS CARD CENTER, CREDIT CARD STATEMENT","","10959.4",""
      "2019-11-04","TRANSFER CH0123456789012345678, FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, E-Banking virement compte à compte","","21502.0",""
      "2019-10-29","PAYMENT FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, PAYMENT, E-Banking virement compte à compte","","1725.0",""
      "2019-10-29","PAYMENT FRAU MACKENZIE EXAMPLE U/O, HERR WALTER WHITE, E-Banking virement compte à compte","","920.53",""
      "2019-10-25","Entrée paiement SIC ","","","16399.8"
      "2019-10-21","A STORE 8001 ZURICH, E-Banking CHF intérieur","","175.4",""
      "2019-10-18","WALTER WHITE BAHNHOFSTRASSE 1, 8001 ZURICH, SOME REFERENCE, SECOND LINE, Entrée paiement SIC","","","53512.0"
      "2019-10-18","Shop AG, 1234 St. Santis","","3010.66",""
      "2019-10-18","EBILL INVOICE SWISSCOM SCHWEIZ AG, 3050 BERN","","1620.0",""
      "2019-10-18","DO IT GARDEN, MIGROS-GENOSSENSCHAFT S-BUND","","199.1",""
      "2019-10-18","EBILL INVOICE ST.PLACE STADTWERKE, 6660 ST. PLACE","","283.0",""
      "2019-10-18","SERAFE TAX","","23450.0",""
    CSV
  end

  before { processor.to_ynab! }

  it 'instantiates' do
    expect(processor).to be_kind_of(Processors::Processor)
  end

  it 'converts the statement' do
    actual = File.read(File.join(File.dirname(__dir__), '..',
                                 'ubschequing_20191018-20191106_ynab4.csv'))

    expect(actual).to eq(processed)
  end
end
