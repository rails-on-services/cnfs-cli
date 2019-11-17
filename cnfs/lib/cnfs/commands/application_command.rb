# frozen_string_literal: true

require 'thor'
require_relative '../command'

module Cnfs
  module Commands
    class ApplicationCommand < Thor
      namespace :application

      register Cnfs::Commands::Application::Backend, 'backend', 'backend [SUBCOMMAND]', 'Run backend commands (short-cut alias: "b")'
      register Cnfs::Commands::Application::Frontend, 'frontend', 'frontend [SUBCOMMAND]', 'Run frontend commands (short-cut alias: "f")'
      register Cnfs::Commands::Application::Pipeline, 'pipeline', 'pipeline [SUBCOMMAND]', 'Run frontend commands (short-cut alias: "p")'
    end
  end
end
