# frozen_string_literal: true

RSpec.describe Processor::Base do
  context 'with any CSV file' do
    before(:context) do
      @file = File.join(File.dirname(__FILE__), 'fixtures/valid.csv')
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

    it "has a `to_ynab!' method" do
      expect(@subject).to respond_to(:to_ynab!)
    end

    it "has a `converters' method stub" do
      subject = -> { @subject.send(:converters) }

      expect(subject).to raise_error(NotImplementedError)
    end
  end
end
