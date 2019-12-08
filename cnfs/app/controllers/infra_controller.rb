# frozen_string_literal: true

require 'thor'
require_relative '../command'

module Cnfs
  module Commands
    class InfraCommand < Thor
      namespace :infra

      register Cnfs::Commands::Infra::Backend, 'backend', 'backend [SUBCOMMAND]', 'Run backend commands (short-cut alias: "b")'
    end
  end
end
