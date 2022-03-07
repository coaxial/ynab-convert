# frozen_string_literal: true

require 'yaml'

module YnabConvert
  # Handles reading configuration from the config file
  class Config
    attr_reader :file_path

    def initialize
      @file_path = compute_file_path
      @config = YAML.safe_load(user_config_or_default, symbolize_names: true)
    end

    def user_config_or_default
      return File.read(@file_path) if File.exist?(@file_path)

      default
    end

    def default
      File.read(File.join(File.dirname(__FILE__), 'default_config.yml'))
    end

    def write_default
      File.write(@file_path, default)
    end

    def get(processor:)
      @config[processor]
    end

    private

    def compute_file_path
      # The config file is named `ynab_convert.yml`.
      # It is located at ~/.config/ynab_convert.yml
      # When running the test suite, the file is located at ./ynab_convert.yml
      # instead, to avoid clobbering the existing config file when developping
      # locally.
      config_filename = 'ynab_convert.yml'

      unless ENV['YNAB_CONVERT_ENV'] == 'test'
        return File.join(Dir.home, '.config', config_filename)
      end

      File.join(File.dirname(File.expand_path('..', __dir__)), config_filename)
    end
  end
end
