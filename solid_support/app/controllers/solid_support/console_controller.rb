# frozen_string_literal: true

module SolidSupport
  class ConsoleController < ApplicationController
    include SolidSupport::ConsoleControllerMethods

# Rename pry commands so they still work but can be reassigned to CLI specific commands
%w[ls cd help].each do |cmd|
  Pry.config.commands["p#{cmd}"] = "Pry::Command::#{cmd.camelize}".constantize
  Pry.config.commands[cmd] = nil
end

Pry::Commands.block_command 'cd', 'change segment' do |path|
  puts "cd: invalid segment: #{path}" unless OneStack::Navigator.current.cd(path)
end

Pry::Commands.block_command 'pwd', 'print segment' do
  OneStack::Navigator.current.path.relative_path_from(OneStack.config.paths.segments).to_s
end

  end
end
