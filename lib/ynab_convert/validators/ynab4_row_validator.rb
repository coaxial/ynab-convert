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

    # Indicates which format the row is in (:flows or :amounts)
    # @param row [CSV::Row] the row to check
    # @return [:flows, :amounts] the row's format
    def self.row_format(row)
      format = :flows
      # :flows has 5 columns: Date, Payee, Memo, Outflow, Inflow
      # :amounts has 4 columns: Date, Payee, Memo, Amount
      format = :amounts if row.length == 4

      format
    end

    # Indiciates whether the amount on the row is valid
    # @param row [CSV::Row] the row to check
    # @return [Boolean] whether the amount is invalid
    def self.amount_valid?(row)
      format = row_format(row)
      indices = [3]
      indices << 4 if format == :flows

      if format == :amounts
        return indices.reduce(true) do |valid, i|
          valid && value_valid?(row[i])
        end
      end

      indices.reduce(false) do |valid, i|
        valid || value_valid?(row[i])
      end
    end

    # Indicates whether a value is valid
    # @param value [#zero?, #nil?, #to_s] the value to check
    # @return [Boolean] whether the value is valid
    def self.value_valid?(value)
      if value.respond_to? :zero?
        !value.zero?
      else
        !value.nil? && !value.to_s.empty?
      end
    end

    # Validates the Date value
    # @note Prefer using the #valid? method
    # @param row [Array<String, Numeric, Date] The row to validate
    # @return [Boolean] Whether the row's Date is invalid
    def self.transaction_date_valid?(row)
      date_index = 0
      date = row[date_index]

      value_valid?(date)
    end

    # Validates the Payee value
    # @note Prefer using the #valid? method
    # @param row [Array<String, Numeric, Date] The row to validate
    # @return [Boolean] Whether the row's Payee is valid
    def self.payee_valid?(row)
      payee_index = 1
      payee = row[payee_index]

      value_valid?(payee)
    end
  end
end
