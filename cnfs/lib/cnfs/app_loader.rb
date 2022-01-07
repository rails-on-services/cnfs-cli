# frozen_string_literal: true

# start_time = Time.now
# lib_path = File.expand_path('../lib', __dir__)
# $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# ENV['CNFS_PROF'] ||= ARGV.delete('--cli-prof')
# dval = ARGV.index('--logging') || ARGV.index('-l')
# ENV['CNFS_LOGGING'] = ARGV[dval + 1] if dval

# Require the cnfs framework and external dependencies
require 'cnfs'

# Require application, extension and plugin base classes after the framework
require 'cnfs/application'

# Add this gem to the plugin hash
require 'cnfs/cnfs_plugin'

# Require the application's environment from <app_root>/config/environment.rb
# The environment requires the application and then calls initialize! which return self
# The application requires boot.rb
# Boot.rb requires the gems, e.g. cnfs-core, cnfs-aws, etc as specified in the Gemfile
require APP_ROOT.join(ROOT_FILE_ID)

# Configure all classes in each plugin's app path to be autoloaded
Cnfs.plugins.values.each do |plugin|
  Cnfs.add_loader(name: :framework, path: plugin.gem_root.join('app'), notifier: plugin)
end

# Setup the autoloader
Cnfs.loaders.values.map(&:setup)

# Run each plugin's initializers
Cnfs.run_initializers

# Invoke the CLI
add_args = ARGV.size.positive? && ARGV.first.start_with?('-')
ARGV.unshift('project', 'console') if ARGV.size.zero? || add_args

# Signal.trap('INT') do
#   warn("\n#{caller.join("\n")}: interrupted")
#   # exit 1
# end

invoked_from_new_generator = ARGV[0].eql?('new')
in_test_mode = ENV['CNFS_CLI_ENV'].eql?('test')
skip_controller_start = invoked_from_new_generator || in_test_mode

unless skip_controller_start
  begin
    # The MainController is empty. The controlling gem needs to add a concern to implement commands
    Cnfs::MainController.start
  rescue Cnfs::Error => e
    puts e.message
    exit 1
  end
end
