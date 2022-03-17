# frozen_string_literal: true

require 'logger'

# Add logging to classes
module YnabLogger
  def logger
    @logger unless @logger.nil?
    @logger ||= Logger.new($stderr)
    @logger.level = Logger::FATAL
    @logger.level = Logger::DEBUG if ENV['YNAB_CONVERT_DEBUG'] == 'true'
    @logger
  end
end
