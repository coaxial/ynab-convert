# frozen_string_literal: true

require 'ynab_convert/transformers/converters/converter'

RSpec.describe Converters::Converter do
  context 'with custom converters' do
    before(:example) do
      Converters::Converter.new(custom_converters: {
                                  my_test_converter: ->(_s) { 'test' }
                                })
    end

    it 'registers them' do
      expect(CSV::Converters.key?(:my_test_converter)).to be(true)
    end
  end
end
