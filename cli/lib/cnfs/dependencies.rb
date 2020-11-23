# frozen_string_literal: true

require 'active_record'
require 'active_record/fixtures'
require 'active_support/core_ext/enumerable'
require 'active_support/log_subscriber'
require 'active_support/string_inquirer'
require 'rails/railtie'  # require before lockbox
# require 'json_schemer'
require 'lockbox'
# require 'open3'
require 'open-uri'
require 'sqlite3'
require 'tty-command'

require_relative 'configuration'
