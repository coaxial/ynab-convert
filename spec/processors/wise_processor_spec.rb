# frozen_string_literal: true

RSpec.describe Processors::Wise do
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
        ""
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
        ""
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
