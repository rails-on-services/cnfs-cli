# frozen_string_literal: true

# Load the classes from <gem_root>/app
require 'logger'
# require 'hendrix'

load_path = Pathname.new(__dir__).join('../../app')
SolidApp.add_loader(name: :framework, path: load_path)

SolidApp.loaders.values.map(&:setup)

# Display the new command's help if no arguments provided
ARGV.append('help', 'new') if ARGV.size.zero?

binding.pry
BOOT_MODULE = SolidApp unless defined?(BOOT_MODULE)
BOOT_MODULE::ProjectCommand.start
