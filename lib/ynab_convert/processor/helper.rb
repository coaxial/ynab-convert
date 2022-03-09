# frozen_string_literal: true

module Processor
  module Helper
    def self.amount_invalid?(row)
      amount_index = 3

      # If there is no amount,
      # then the row is invalid.
      row[amount_index].nil? || row[amount_index].empty?
    end

    def self.inflow_outflow_invalid?(row)
      inflow_index = 3
      outflow_index = 4

      # If there is neither inflow and outflow values,
      # or both the inflow and outflow amounts are 0,
      # then the row is invalid.
      (
        row[inflow_index].nil? ||
        row[inflow_index].empty? ||
        row[inflow_index] == '0.00'
      ) && (
        row[outflow_index].nil? ||
        row[outflow_index].empty? ||
        row[outflow_index] == '0.00'
      )
    end

    def self.amounts_missing?(row:, format:)
      if format == :amounts
        amount_invalid?(row)
      else
        inflow_outflow_invalid?(row)
      end
    end

    def self.transaction_date_missing?(ynab_row)
      ynab_row[0].nil? || [0].empty?
    end

    def self.extract_transaction_date(ynab_row)
      transaction_date_index = 0
      ynab_row[transaction_date_index]
    end

    def self.date_is_more_recent?(date)
      statement_to.nil? || statement_to < date
    end

    def self.date_is_further_away?(date)
      statement_from.nil? || statement_from > date
    end
  end
end
