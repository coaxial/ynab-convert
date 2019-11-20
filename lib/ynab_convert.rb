# frozen_string_literal: true

require 'ynab_convert/version'

module YnabConvert
  # Metadata about the gem
  class Metadata
    def  short_desc
      puts 'A utility to convert online banking CSV files to a format that ' \
'can be imported into YNAB 4.'
    end

    def version
      puts "YNAB Convert #{YnabConvert::VERSION}"
    end
  end

  # Parse command line arguments
  class OptionsParser
    def options
      Slop.parse do |o|
        o.on '-v', '--version', 'print the version' do
          puts Metadata.version
          exit
        end
      end
    end
  end

  # Operations on the CSV file to convert
  class File
    # @option opts [String] :file The filename or path to the file
    # @option opts [Processor] :processor The class to use for converting the
    # CSV file
    def initialize(opts)
      @file = opts[:file]
      halt_and_catch_fire unless ::File.exist?(@file)

      @processor = opts[:processor].new @file
    end

    # Converts @file to YNAB4 format and writes it to disk
    # @return [String] The path to the YNAB4 formatted CSV file created
    def to_ynab!
      @processor.to_ynab!
    end

    private

    def halt_and_catch_fire
      enoent = 2

      warn "File `#{@file}' not found or not accessible."
      exit(enoent)
    end
  end
end
