# frozen_string_literal: true

require 'thor'
require_relative '../command'

module Cnfs
  module Commands
    class InfraC < Thor

      namespace :infra

      require_relative 'infra/backend'
      register Cnfs::Commands::Infra::Backend, 'backend', 'backend [SUBCOMMAND]', 'Run backend commands (short-cut alias: "b")'
    end
  end
end
