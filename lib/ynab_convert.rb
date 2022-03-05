# frozen_string_literal: true

require 'ynab_convert/version'
require 'slop'
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
      logger.debug opts.to_h
      @file = opts[:file]

      begin
        @processor = opts[:processor].new(
          file: @file
        )
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
      @options = parse_argv
      return unless no_options_given

      show_usage
      exit
    end

    def start
      @file = File.new opts
      logger.debug "Using processor `#{@options[:institution]}' => #{processor}"
      @file.to_ynab!
    end

    private

    def opts
      { file: @options[:file], processor: processor }
    rescue NameError => e
      raise e unless e.message.match(/#{processor_class_name}/)

      logger.debug "#{@options.to_h}, #{processor_class_name}"
      show_unknown_institution_message
      exit false
    end

    def parse_argv
      Slop.parse do |o|
        o.on '-v', '--version', 'print the version' do
          puts @metadata.version
          exit
        end
        o.string '-i', '--institution', 'name of the financial institution '\
 'that generated the file to convert'
        o.string '-f', '--file', 'path to the csv file to convert'
      end
    end

    def processor_class_name
      "Processor::#{@options[:institution].camel_case}"
    end

    def processor
      processor_class_name.split('::').inject(Object) { |o, c| o.const_get c }
    end

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
        'contributing a new processor (see https://github.com/coaxial/'\
        'ynab_convert#contributing to get started).'
    end
  end
end
