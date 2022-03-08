# frozen_string_literal: true

require 'yaml'

module YnabConvert
  # Handles reading configuration from the config file
  class Config
    attr_reader :user_file_path

    def initialize
      @skel_file_path = File.join(
        File.dirname(__FILE__),
        'default_config.yml'
      )
      @user_file_path = compute_user_file_path
      @config = YAML.safe_load(user_config_or_default, symbolize_names: true)
    end

    def user_config_or_default
      return File.read(@user_file_path) if File.exist?(@user_file_path)

      default
    end

    def default
      File.read(@skel_file_path)
    end

    def write_default
      if user_config_present?
        raise Errno::EEXIST,
              "User config file already exists at #{@user_file_path}"
      end

      FileUtils.cp(@skel_file_path, @user_file_path)
    end

    def user_config_present?
      File.exist?(@user_file_path)
    end

    # @option processor [Symbol] :processor Class name of the processor to get the
    #   configuration for
    def get(processor:)
      @config[processor]
    end

    private

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
