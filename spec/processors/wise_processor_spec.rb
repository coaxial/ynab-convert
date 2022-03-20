# frozen_string_literal: true

RSpec.describe Processors::Wise, :vcr do
  let(:chf_fixture_path) do
    File.join(File.dirname(__dir__),
              'fixtures/statements/wise_chf_fixture.csv')
  end
  let(:eur_fixture_path) do
    File.join(File.dirname(__dir__),
              'fixtures/statements/wise_eur_fixture.csv')
  end

  context 'with a CHF statement' do
    let(:processor) { described_class.new(filepath: chf_fixture_path) }
    let(:processed) do
      <<~CSV
        "Date","Payee","Memo","Amount"
        "2021-12-23","Someone Someplace","Original amount: 10.00 USD","-3.05"
        "2021-12-16","Lala Australia +61408655667","Original amount: 11.00 CHF","-11.0"
        "2021-11-13","Lala Australia +61408655667","Original amount: 11.00 CHF","-0.07"
        "2021-11-13","Someone Someplace","Original amount: 10.00 USD","-9.25"
        "2021-11-11","Merchant merchant.com LOCATION LOCATION","Original amount: 30.00 EUR","-31.82"
      CSV
    end

    before { processor.to_ynab! }

    it 'inherits from Processors::Processor' do
      expect(processor).to be_a(Processors::Processor)
    end

    it 'processes the statement' do
      actual = File.read(File.join(File.dirname(__dir__), '..',
                                   'wise_20211111-20211223_ynab4.csv'))

      expect(actual).to eq(processed)
    end
  end

  context 'with a EUR statement' do
    let(:processor) { described_class.new(filepath: eur_fixture_path) }
    let(:processed) do
      <<~CSV
        "Date","Payee","Memo","Amount"
        "2021-12-23","Someplace Location","Original amount: 10.00 USD","-6.18"
        "2021-12-18","Merchant 0*00-00000-00000 Luxembourg","Original amount: 2.83 EUR","2.94"
        "2021-12-16","Merchant 0*00-00000-00000 Luxembourg","Original amount: 3.10 EUR","3.24"
        "2021-11-23","merchant.com Luxembourg","Original amount: 9.51 USD","-4.19"
        "2021-11-22","Merchant O*00-00000-00000 Luxembourg","Original amount: 4.00 EUR","4.19"
      CSV
    end

    before { processor.to_ynab! }

    it 'inherits from Processors::Processor' do
      expect(processor).to be_a(Processors::Processor)
    end

    it 'processes the statement' do
      actual = File.read(File.join(File.dirname(__dir__), '..',
                                   'wise_20211122-20211223_ynab4.csv'))

      expect(actual).to eq(processed)
    end
  end
end
