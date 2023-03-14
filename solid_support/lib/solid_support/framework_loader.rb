# frozen_string_literal: true

# Load the classes from <gem_root>/app
require 'logger'

# load_path = Pathname.new(__dir__).join('../../app')
# SolidSupport.add_loader(name: :framework, path: load_path) if load_path.exist?
# SolidSupport.load_all

# Display the new command's help if no arguments provided
ARGV.append('help', 'new') if ARGV.size.zero?

# The project enclosing this gem must define the ProjectCommand class
cmd_object = defined?(ProjectCommand) ? ProjectCommand : BOOT_MODULE::ProjectCommand
# binding.pry
cmd_object.start
