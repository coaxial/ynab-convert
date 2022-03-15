# frozen_string_literal: true

module Documents
  module Statements
    # The base Statement class from which other Statements inherit.
    # Represents a CSV statement from a financial institution, typically from
    # its online banking portal.
    class Statement
      attr_reader :csv_import_options
      attr_reader :filepath

      # @param filepath [String] path to the CSV file
      # @param csv_import_options [CSV::DEFAULT_OPTIONS] options describing
      #   the particular CSV flavour (column separator, etc). Any
      #   CSV::DEFAULT_OPTIONS is valid.
      def initialize(filepath:, csv_import_options: CSV::DEFAULT_OPTIONS)
        validate(filepath)

        @filepath = filepath
        @csv_import_options = csv_import_options
      end

      def institution_name
        self.class.name.split('::').last
      end

      private

      # Verifies that the file exists at path, raises an error if not.
      # @param path [String] path to the file
      def validate(path)
        return if ::File.exist?(path)

        raise Errno::ENOENT, "file not found #{path}"
      end
    end
  end
end
