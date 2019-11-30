# frozen_string_literal: true

require 'ynab_convert/version'
require 'slop'
require 'pry'
require 'ynab_convert/logger'
require 'core_extensions/string.rb'

# The application
module YnabConvert
  # Metadata about the gem
  class Metadata
    def  short_desc
      puts 'An utility to convert online banking CSV files to a format that ' \
'can be imported into YNAB 4.'
    end

    def version
      puts "YNAB Convert #{YnabConvert::VERSION}"
    end
  end

  # Operations on the CSV file to convert
  class File
    include YnabLogger

    # @option opts [String] :file The filename or path to the file
    # @option opts [Processor] :processor The class to use for converting the
    # CSV file
    def initialize(opts)
      @file = opts[:file]

      begin
        @processor = opts[:processor].new(file: @file)
      rescue Errno::ENOENT
        handle_file_not_found
      end
    end

    # Converts @file to YNAB4 format and writes it to disk
    # @return [String] The path to the YNAB4 formatted CSV file created
    def to_ynab!
      logger.debug "Processing `#{@file}' through `#{@processor.class.name}'"
      @processor.to_ynab!
    end

    private

    def file_not_found_message
      raise Errno::ENOENT, "File `#{@file}' not found or not accessible."
    end
  end

  # The command line interface methods
  class CLI
    include YnabLogger
    include CoreExtensions::String::Inflections

    def initialize
      @metadata = Metadata.new
      @options = Slop.parse do |o|
        o.on '-v', '--version', 'print the version' do
          puts @metadata.version
          exit
        end
        o.string '-i', '--institution', 'the financial institution for the ' \
       ' statement to process'
        o.string '-f', '--file', 'path to the statement to process'
      end

      if no_options_given
        show_usage
        exit
      end
    end

    def start
      processor_class_name = "Processor::#{@options[:institution].camel_case}"
      begin
        processor = processor_class_name.split('::').inject(Object) { |o, c| o.const_get c }
      rescue NameError => e
        if e.message.match(/#{processor_class_name}/)
          show_unknown_institution_message
          logger.debug "#{@options.to_h}, #{processor_class_name}"
        end
        raise e
      end

      opts = { file: @options[:file], processor: processor }

      logger.debug "Using processor `#{@options[:institution]}' => #{processor}"

      @file = File.new opts
      @file.to_ynab!
    end

    private

    def no_options_given
      @options[:institution].nil? || @options[:file].nil?
    end

    def show_usage
      puts @metadata.short_desc
      puts @options
    end

    def show_unknown_institution_message
      warn 'Could not find any processor for the institution '\
        "`#{@options[:institution]}'. If it's not a typo, consider "\
        'contributing a new processor.'
    end
  end
end
