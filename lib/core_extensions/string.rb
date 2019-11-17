# frozen_string_literal: true

module CoreExtensions
  module String
    module Inflections
      def snake_case
        downcase.tr(' ', '_').gsub(/[^a-z_]/, '')
      end
    end
  end
end
