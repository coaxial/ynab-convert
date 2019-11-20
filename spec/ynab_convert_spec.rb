# frozen_string_literal: true

require 'helpers/dummy_processor.rb'

RSpec.describe YnabConvert do
  it 'has a version number' do
    expect(YnabConvert::VERSION).not_to be nil
  end

  describe YnabConvert::Metadata do
    before(:example) do
      @subject = YnabConvert::Metadata.new
    end

    it 'can show a short description' do
      expected = 'A utility to convert online banking CSV files to a format' \
    " that can be imported into YNAB 4.\n"

      expect { @subject.short_desc }.to output(expected).to_stdout
    end

    it 'can show its version' do
      expected = "YNAB Convert #{YnabConvert::VERSION}\n"

      expect { @subject.version }.to output(expected).to_stdout
    end
  end

  describe YnabConvert::File do
    context 'with a non-existent file' do
      before(:example) do
        @filename = 'doesnt_exist.csv'
        @opts = { file: @filename, processor: Processor::Dummy }
        @subject = -> { YnabConvert::File.new(@opts) }
      end

      it 'shows a friendly error message' do
        expected = "File `#{@filename}' not found or not accessible."

        begin
          expect(@subject).to output(expected).to_stderr
        rescue SystemExit # rubocop:disable all
        end
      end

      it 'exits with code 2 (ENOENT)' do
        enoent = 2

        expect(@subject).to exit_with_code(enoent)
      end
    end

    context 'with an existing file' do
      context 'that is valid CSV' do
        before(:example) do
          @filename = 'exists.csv'
          @opts = { file: @filename }
          @subject = YnabConvert::File.new @opts
        end

        it 'converts it'
      end

      context 'that is invalid CSV' do
        before(:example) do
          @filename = 'exists.txt'
          @opts = { file: @filename }
          @subject = YnabConvert::File.new @opts
        end

        it 'prints an error message'
      end
    end
  end
end
