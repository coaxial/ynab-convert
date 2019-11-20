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
      @processor = opts[:processor].new @file
    end

    # Converts @file to YNAB4 format and writes it to disk
    # @return [CSV::Row] The result of converting @file to YNAB4 format
    def to_ynab!
      @processor.to_ynab!
    end
  end
end
