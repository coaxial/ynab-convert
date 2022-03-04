# frozen_string_literal: true

RSpec.describe Processor::Base do
  context 'with any CSV file' do
    fixture_path = 'fixtures/example/valid.csv'

    before(:context) do
      @file = File.join(File.dirname(__FILE__), fixture_path)
      @institution_name = 'Mesa Credit Union'
      @from = Time.local(1986, 'jul', 25, 0, 30, 0)
      @to = Time.local(1986, 'nov', 12, 5, 0, 0)

      @subject = Processor::Base.new(file: @file)

      @subject.instance_variable_set('@statement_from', @from)
      @subject.instance_variable_set('@statement_to', @to)
      @subject.instance_variable_set('@institution_name', @institution_name)
    end

    it 'should initialize' do
      expect(@subject).to be_an_instance_of(Processor::Base)
    end

    it 'should compute the right output filename' do
      actual = @subject.send(:output_filename)
      expected = "#{File.basename(@file, '.csv')}_" \
        "#{@institution_name.snake_case}_#{@from.strftime('%Y%m%d')}-" \
        "#{@to.strftime('%Y%m%d')}_ynab4.csv"

      expect(actual).to eq(expected)
    end

    it 'should work in :flows format by default' do
      actual = @subject.instance_variable_get('@headers')
      expected = { transaction_date: nil, payee: nil, inflow: nil, outflow: nil }

      expect(actual).to eq(expected)
    end

    it "has a `to_ynab!' method" do
      expect(@subject).to respond_to(:to_ynab!)
    end

    it "has a `transformers' method stub" do
      subject = -> { @subject.send(:transformers) }

      expect(subject).to raise_error(NotImplementedError)
    end

    context 'using :amounts format' do
      let(:subject) { Processor::Base.new(file: @file, format: :amounts) }

      it 'should have amounts columns' do
        actual = subject.instance_variable_get('@headers')
        expected = { transaction_date: nil, payee: nil, amount: nil }

        expect(actual).to eq(expected)
      end
    end

    context 'using :flows format' do
      let(:subject) { Processor::Base.new(file: @file, format: :flows) }

      it 'should have flows columns' do
        actual = subject.instance_variable_get('@headers')
        expected = { transaction_date: nil, payee: nil, inflow: nil, outflow: nil }

        expect(actual).to eq(expected)
      end
    end

    context 'when omitting the file path' do
      subject = -> { Processor::Base.new }

      it 'throws an error' do
        expect { subject.call }.to raise_error(::Errno::ENOENT)
      end
    end
  end
end
