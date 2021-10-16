# frozen_string_literal: true

require 'active_record'
require 'active_support/log_subscriber'
require 'active_support/string_inquirer'

# require 'json_schemer'
# require 'open3'
require 'open-uri'
require 'sqlite3'
require 'tty-command'
require 'tty-prompt'
require 'tty-table'

require_relative 'data_store'
require_relative 'tty/prompt'
require_relative 'tty/prompt/answers_collector'
