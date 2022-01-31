# frozen_string_literal: true

# start_time = Time.now
# lib_path = File.expand_path('../lib', __dir__)
# $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# ENV['HENDRIX_PROF'] ||= ARGV.delete('--cli-prof')
# dval = ARGV.index('--logging') || ARGV.index('-l')
# ENV['HENDRIX_LOGGING'] = ARGV[dval + 1] if dval

# Require the hendrix framework and external dependencies
require 'hendrix'

# Require application, extension and plugin base classes after the framework
require 'hendrix/application'

# Add this gem to the plugin hash
require 'hendrix/hendrix_plugin'

# Require the application's environment from <app_root>/config/environment.rb
# The environment requires the application and then calls initialize! which return self
# The application requires boot.rb
# Boot.rb requires gems as specified in the Gemfile
# Afte this each gem, e.g. lyrics and tunes, will have been required
require APP_ROOT.join(ROOT_FILE_ID)

# First configurable block to run. Called before any initializers are run.
Hendrix::Lyric.before_configuration.each { |blk| blk.call(Hendrix.config) }

# Second configurable block to run. Called before frameworks initialize.
Hendrix::Lyric.before_initialize.each { |blk| blk.call(Hendrix.config) }
binding.pry

# Run each plugin's initializers; Initialzier do not have access to classes in app dir
# at this point
# Hendrix.run_initializers
 
# Third configurable block to run; Still don't have access to classes in app
Hendrix::Lyric.before_eager_load.each { |blk| blk.call(Hendrix.config) }

# Configure all classes in each plugin's app path to be autoloaded
Hendrix.load_tunes

# Setup the autoloader; Requires all classes in the app dir
Hendrix.loaders.values.map(&:setup)

# Last configurable block to run. Called after frameworks initialize.
# Here have access to all classes in app
Hendrix::Lyric.after_initialize.each { |blk| blk.call(Hendrix.config) }

# Invoke the CLI
add_args = ARGV.size.positive? && ARGV.first.start_with?('-')
ARGV.unshift('project', 'console') if ARGV.size.zero? || add_args

# Signal.trap('INT') do
#   warn("\n#{caller.join("\n")}: interrupted")
#   # exit 1
# end

invoked_from_new_generator = ARGV[0].eql?('new')
in_test_mode = ENV['HENDRIX_CLI_ENV'].eql?('test')
skip_controller_start = invoked_from_new_generator || in_test_mode

unless skip_controller_start
  begin
    # The MainCommand class is defined in the application
    MainCommand.start
  rescue Hendrix::Error => e
    puts e.message
    exit 1
  end
end
