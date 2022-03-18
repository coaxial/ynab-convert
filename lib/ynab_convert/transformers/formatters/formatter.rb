# frozen_string_literal: true

module Transformers
  module Formatters
    # Formats Statements rows into YNAB4 rows (Date, Payee, Memo, Amount or
    # Outflow and Inflow.)
    class Formatter
      # @param [Hash] headers_indices the indices at which to find each
      #   header's name
      # @option  headers_indices [Array<Numeric>] :date transaction date
      # @option  headers_indices [Array<Numeric>] :payee transaction
      #   payee/description
      # @option  headers_indices [Array<Numeric>] :memo transaction memo or
      #   currency if currency conversion will be performed
      # @option  headers_indices [Array<Numeric>] :amount transaction amount (if
      #   Statement is using the :amounts format)
      # @option  headers_indices [Array<Numeric>] :outflow transaction outflow
      #   (if using the :flows format)
      # @option  headers_indices [Array<Numeric>] :inflow transaction inflow (if
      #   using the :flows format)
      def initialize(**headers_indices)
        default_values = {
          memo: [] # The Memo field tends to be empty for most institutions
        }

        @format = :flows
        unless headers_indices[:amount].nil? || headers_indices[:amount].empty?
          @format = :amounts
        end
        @headers_indices = default_values.merge(headers_indices)
      end

      # Turns CSV rows into YNAB4 rows (Date, Payee, Memo, Amount or Outflow and
      # Inflow)
      # @param row [CSV::Row] The CSV row to parse
      # @return [Array<String>] The YNAB4 formatted row
      def run(row)
        ynab_row = [date(row), payee(row), memo(row)]

        if @format == :amounts
          ynab_row << amount(row)
        else
          ynab_row << outflow(row)
          ynab_row << inflow(row)
        end

        ynab_row
      end

      # Processes columns for each row. Based on the method name that is called,
      # it will extract the corresponding column (field).
      # @note In more complex cases, some heuristics are required to format some
      #   of the columns. In that case, any of the aliased #field methods
      #   (#date, #payee, #memo, #amount, #outflow, #inflow) can be
      #   overridden in the child.
      # @param row [CSV::Row] The row to process
      # @return [String] The corresponding field(s)
      def field(row)
        # Figure out the aliased name the method was called with, to derive
        # which field to return from the row.
        requested_field = __callee__.to_sym
        assembled_field = @headers_indices[requested_field].reduce([]) do
          |fields_data, i|
          fields_data << row[i]
        end

        # Avoid turning Dates and Numerics back to strings
        # If the assembled_field isn't a composite from several Statement
        # fields, there is no need to join(' ') and turn it into a String
        formatted_field = assembled_field[0]
        if assembled_field.length > 1
          formatted_field = assembled_field.join(' ')
        end

        # Avoid "nil" values in the output
        return '' if formatted_field.nil?

        formatted_field
      end

      # Create alias names for the field method. This allows the function to
      # figure out which field to extract from its method name.
      alias date field
      alias payee field
      alias memo field
      alias amount field
      alias outflow field
      alias inflow field
    end
  end
end
