# frozen_string_literal: true

RSpec.describe Processor::Base do
  context 'with any CSV file' do
    fixture_path = 'fixtures/example/valid.csv'
    full_path = File.join(File.dirname(__FILE__), fixture_path)

    let(:file) { full_path }
    let(:institution_name) { 'Mesa Credit Union' }
    let(:from) { Time.local(1986, 'jul', 25, 0, 30, 0) }
    let(:to) { Time.local(1986, 'nov', 12, 5, 0, 0) }
    let(:subject) do
      instance = Processor::Base.new(file: full_path)
      instance.instance_variable_set('@statement_from', from)
      instance.instance_variable_set('@statement_to', to)
      instance.instance_variable_set('@institution_name', institution_name)

      instance
    end

    it 'initializes' do
      expect(subject).to be_an_instance_of(Processor::Base)
    end

    it 'computes the right output filename' do
      actual = subject.send(:output_filename)
      expected = "#{File.basename(file, '.csv')}_" \
        "#{institution_name.snake_case}_#{from.strftime('%Y%m%d')}-" \
        "#{to.strftime('%Y%m%d')}_ynab4.csv"

      expect(actual).to eq(expected)
    end

    it 'works in :flows format by default' do
      actual = subject.instance_variable_get('@headers')
      expected = {
        transaction_date: nil,
        payee: nil,
        inflow: nil,
        outflow: nil
      }

      expect(actual).to eq(expected)
    end

    it "has a `to_ynab!' method" do
      expect(subject).to respond_to(:to_ynab!)
    end

    it "has a `transformers' method stub" do
      lambda = -> { subject.send(:transformers) }

      expect(lambda).to raise_error(NotImplementedError)
    end

    context 'using :amounts format' do
      let(:subject) { Processor::Base.new(file: file, format: :amounts) }

      it 'has an amounts columns' do
        actual = subject.instance_variable_get('@headers')
        expected = { transaction_date: nil, payee: nil, amount: nil }

        expect(actual).to eq(expected)
      end
    end

    context 'using :flows format' do
      let(:subject) { Processor::Base.new(file: file, format: :flows) }

      it 'has a flows columns' do
        actual = subject.instance_variable_get('@headers')
        expected = {
          transaction_date: nil,
          payee: nil,
          inflow: nil,
          outflow: nil
        }

        expect(actual).to eq(expected)
      end
    end

    context 'when omitting the file path' do
      lambda = -> { Processor::Base.new({}) }

      it 'throws an error' do
        expect { lambda.call }.to raise_error(::Errno::ENOENT)
      end
    end
  end
end
