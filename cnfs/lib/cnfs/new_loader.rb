# frozen_string_literal: true

# Load the classes from <gem_root>/app
require 'logger'
require 'cnfs/loader'
require 'thor'

load_path = Pathname.new(__dir__).join('../../app')
Cnfs.add_loader(name: :framework, path: load_path).setup

# Display the new command's help if no arguments provided
ARGV.append('help', 'new') if ARGV.size.zero?

# Start the NewController
Cnfs::New::CommandController.start
