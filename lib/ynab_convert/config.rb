# frozen_string_literal: true

require 'yaml'

module YnabConvert
  # Handles reading configuration from the config file. See
  # `lib/ynab_convert/default_config.yml` for an example configuration file.
  class Config
    attr_reader :user_file_path

    def initialize
      @skel_file_path = File.join(
        File.dirname(__FILE__),
        'default_config.yml'
      )
      @user_file_path = compute_user_file_path
      @config = YAML.safe_load(user_config_or_default, symbolize_names: true) || {}
    end

    # @return [String] The configuration to use
    def user_config_or_default
      return File.read(@user_file_path) if File.exist?(@user_file_path)

      default
    end

    # @return [String] The default configuration
    def default
      File.read(@skel_file_path)
    end

    # Writes the default config to the user's home
    # @return [Nil]
    def write_default
      if user_config_present?
        raise Errno::EEXIST,
              "User config file already exists at #{@user_file_path}"
      end

      FileUtils.cp(@skel_file_path, @user_file_path)
    end

    # @return [Boolean] Whether a user config file exists
    def user_config_present?
      File.exist?(@user_file_path)
    end

    # Fetches top-level keys from the configuration.
    # @param key [Symbol] Top-level key to get
    # @return [Hash] Value at matching key
    def get(key:)
      @config.fetch(key, {})
    end

    private

    # Calculate the user's configuration file path. It typically is
    # `~/.config/ynab_convert.yml` except when running tests, to avoid
    # overwriting an existing config file while running tests locally.
    # @return [String] Path to configuration file
    def compute_user_file_path
      # The config file is named `ynab_convert.yml`.
      # It is located at ~/.config/ynab_convert.yml
      user_file_path = File.join(
        File.dirname(File.expand_path('..', __dir__)),
        'ynab_convert.yml'
      )
      # When running the test suite, the file is located at ./ynab_convert.yml
      # instead, to avoid clobbering the existing config file when developping
      # locally.
      unless ENV['YNAB_CONVERT_ENV'] == 'test'
        user_file_path = File.join(Dir.home, '.config', 'ynab_convert.yml')
      end

      user_file_path
    end
  end
end
