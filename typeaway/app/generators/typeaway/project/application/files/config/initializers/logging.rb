# frozen_string_literal: true

# Documentation: https://github.com/piotrmurach/tty-logger

# Custom logger
Hendrix.logger = TTY::Logger.new do |config|
  config.level = :warn
  # config.handlers = [[:stream, formatter: :json]]
  # config.output = File.open('/tmp/errors.log', 'w')
  # https://github.com/piotrmurach/tty-logger#241-metadata
  # config.metadata = [:file]
  config.metadata = [:date, :time]
end

# require 'tty-logger-raven'

# TTY::Logger.new do |c|
#   c.handlers = [[:raven, {}]]
# end
