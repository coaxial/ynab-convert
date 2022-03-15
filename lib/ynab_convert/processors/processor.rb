# frozen_string_literal: true

require 'ynab_convert/documents'
require 'ynab_convert/validators'

module Processors
  # A processor instantiates the Documents and Transformers required to turn a
  # Statement into a YNAB4File
  class Processor
    # @param statement [Documents::Statement] The CSV statement to process
    # @param ynab4_file [Documents::YNAB4Files::YNAB4File] An instance of
    #   YNAB4File
    # @param converters [Hash<Symbol, Proc>] A hash of converters to process
    #   each Statement row. The key is the name of the custom converter.
    #   The Proc receives the cell's content as a string and returns the
    #   converted value. See CSV::Converters.
    # @param transformers [Array<Transformers::Transformer>] The Transformers
    #   to run in sequense
    def initialize(statement:, ynab4_file:, converters: {}, transformers:)
      @statement = statement
      @transformers = transformers
      @validators = [::Validators::YNAB4Row]
      @uid = rand(36**8).to_s(36)
      @ynab4_file = ynab4_file
      register_converters(converters)
    end

    def to_ynab!
      convert
      rename_temp_file
    end

    private

    def convert
      CSV.open(temp_filepath, 'wb',
               **@ynab4_file.csv_export_options) do |ynab4_csv|
        CSV.foreach(@statement.filepath, 'rb',
                    **@statement.csv_import_options) do |statement_row|
          transformed_row = @transformers.reduce(statement_row) do |row, t|
            t.run(row)
          end

          row_valid = @validators.reduce(true) do |is_valid, v|
            is_valid && v.valid?(transformed_row)
          end

          if row_valid
            @ynab4_file.update_dates(transformed_row)
            ynab4_csv << transformed_row
          end
        end
      end
    end

    def register_converters(converters)
      converters.each do |name, block|
        CSV::Converters[name] = block
      end
    end

    def temp_filepath
      basename = File.basename(@statement.filepath, '.csv')
      financial_institution = @statement.institution_name

      "#{basename}_#{financial_institution.snake_case}_#{@uid}_ynab4.csv"
    end

    def rename_temp_file
      FileUtils.mv(temp_filepath, @ynab4_file.filename)
    end
  end
end
