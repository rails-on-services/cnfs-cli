# frozen_string_literal: true

require 'thor'
require_relative '../command'

module Cnfs
  module Commands
    class ApplicationC < Thor

      namespace :application

      require_relative 'application/backend'
      register Cnfs::Commands::Application::Backend, 'backend', 'backend [SUBCOMMAND]', 'Run backend commands (short-cut alias: "b")'

      require_relative 'application/frontend'
      register Cnfs::Commands::Application::Frontend, 'frontend', 'frontend [SUBCOMMAND]', 'Run frontend commands (short-cut alias: "f")'

      require_relative 'application/pipeline'
      register Cnfs::Commands::Application::Pipeline, 'pipeline', 'pipeline [SUBCOMMAND]', 'Run frontend commands (short-cut alias: "p")'
    end
  end
end
