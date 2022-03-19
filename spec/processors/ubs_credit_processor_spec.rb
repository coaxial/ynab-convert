# frozen_string_literal: true

RSpec.describe Processors::UBSCredit do
  let(:fixture_path) do
    File.join(File.dirname(__dir__),
              'fixtures/statements/ubs_credit_fixture.csv')
  end
  let(:processor) { described_class.new(filepath: fixture_path) }
  let(:processed) do
    <<~CSV
      "Date","Payee","Memo","Outflow","Inflow"
      "2019-10-28","TWINT  *Post CH AG       St. Moritz   CHE","","1215.0",""
      "2019-11-02","Revolut*1234*            revolut.com  GBR","","2500.0",""
      "2019-11-04","Revolut*1234*            revolut.com  GBR","","2500.0",""
      "2019-11-06","TWINT  *Some Company     Renens       CHE","","199.0",""
      "2019-11-07","Revolut*1234*            revolut.com  GBR","","300.0",""
      "2019-11-07","TWINT  *SBB Mobile       Bern         CHE","","2.2",""
      "2019-11-11","Revolut*1234*            revolut.com  GBR","","130.0",""
      "2019-11-11","Revolut*1234*            revolut.com  GBR","","500.0",""
      "2019-11-11","Revolut*1234*            revolut.com  GBR","","1000.0",""
    CSV
  end

  before { processor.to_ynab! }

  it 'inherits from Processors::Processor' do
    expect(processor).to be_a(Processors::Processor)
  end

  it 'processes the statement' do
    actual = File.read(File.join(File.dirname(__dir__), '..',
                                 'ubscredit_20191028-20191111_ynab4.csv'))

    expect(actual).to eq(processed)
  end
end
