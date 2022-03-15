# frozen_string_literal: true

module Validators
  # Checks YNAB4 row for validity. A row is valid if it has a Date, Payee, and
  # one of Amount, Outflow, Inflow.
  module YNAB4Row
    # Validates a row
    # @param row [Array<String, Numeric, Date>] The row to validate
    # @return [Boolean] Whether the row is valid
    def self.valid?(row)
      # we are dealing with a YNAB4 row:
      # %w[Date Payee Memo Amount|Outflow Inflow]
      amount_valid?(row) &&
        transaction_date_valid?(row) &&
        payee_valid?(row)
    end

    # Validates the Amount or the Inflow and Outflow values
    # @note Prefer using the #valid? method
    # @param row [Array<String, Numeric, Date] The row to validate
    # @return [Boolean] Whether the row's Amount or Inflow and Outflow is valid
    def self.amount_valid?(row)
      # An amount is invalid either if:
      #   - the Amount value is empty or 0
      #   - the Inflow and Outflow values are both empty or 0
      # Whether Amount or Inflow and Outflow are checked depends on the YNAB4
      # format for that row (:flows or :amounts)
      return !amount_is_invalid?(row) if row_format(row) == :amounts

      !(inflow_is_invalid?(row) && outflow_is_invalid?(row))
    end

    def self.row_format(row)
      format = :flows
      # :flows has 5 columns: Date, Payee, Memo, Outflow, Inflow
      # :amounts has 4 columns: Date, Payee, Memo, Amount
      format = :amounts if row.length == 4

      format
    end

    def self.amount_is_invalid?(row)
      amount_index = 3
      (
        row[amount_index].nil? ||
        row[amount_index].empty? ||
        row[amount_index] == '0.0'
      )
    end

    def self.inflow_is_invalid?(row)
      inflow_index = 4
      (
        row[inflow_index].nil? ||
        row[inflow_index].empty? ||
        row[inflow_index] == '0.0'
      )
    end

    def self.outflow_is_invalid?(row)
      outflow_index = 3
      (
        row[outflow_index].nil? ||
        row[outflow_index].empty? ||
        row[outflow_index] == '0.0'
      )
    end

    # Validates the Date value
    # @note Prefer using the #valid? method
    # @param row [Array<String, Numeric, Date] The row to validate
    # @return [Boolean] Whether the row's Date is valid
    def self.transaction_date_valid?(row)
      date_index = 0

      !(row[date_index].nil? || row[date_index].empty?)
    end

    # Validates the Payee value
    # @note Prefer using the #valid? method
    # @param row [Array<String, Numeric, Date] The row to validate
    # @return [Boolean] Whether the row's Payee is valid
    def self.payee_valid?(row)
      payee_index = 1

      !(row[payee_index].nil? || row[payee_index].empty?)
    end
  end
end
