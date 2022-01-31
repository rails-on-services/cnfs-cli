# frozen_string_literal: true

# Load the classes from <gem_root>/app
require 'logger'
require 'hendrix'

load_path = Pathname.new(__dir__).join('../../app')
Hendrix.add_loader(name: :framework, path: load_path)

Hendrix.loaders.values.map(&:setup)

# Display the new command's help if no arguments provided
ARGV.append('help', 'new') if ARGV.size.zero?

BOOT_MODULE = Hendrix unless defined?(BOOT_MODULE)
BOOT_MODULE::ProjectCommand.start
