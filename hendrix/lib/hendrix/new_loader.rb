# frozen_string_literal: true

# Load the classes from <gem_root>/app
require 'logger'
require 'hendrix/loader'
require 'thor'
require 'solid-support'

load_path = Pathname.new(__dir__).join('../../app')
Hendrix.add_loader(name: :framework, path: load_path).setup

# Display the new command's help if no arguments provided
ARGV.append('help', 'new') if ARGV.size.zero?

# Start the NewController
# Hendrix::New::CommandController.start
Hendrix::NewCommand.start
