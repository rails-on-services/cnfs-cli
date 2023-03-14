# frozen_string_literal: true

# start_time = Time.now
# lib_path = File.expand_path('../lib', __dir__)
# $LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# ENV['HENDRIX_PROF'] ||= ARGV.delete('--cli-prof')
# dval = ARGV.index('--logging') || ARGV.index('-l')
# ENV['HENDRIX_LOGGING'] = ARGV[dval + 1] if dval

# Require the solid_support framework and external dependencies
# require 'solid_support'

# Require application, extension and plugin base classes after the framework
require_relative 'application'

# Require the application's environment from <app_root>/config/environment.rb
# The environment then requires the application at ./application.rb
# application.rb requires boot.rb
# boot.rb requires gems as specified in the Gemfile
# After this each gem, e.g. plugins and extensions, will have been required
# Finally environment.rb calls initialize! which return self
require APP_ROOT.join(ROOT_FILE_ID)

# Signal.trap('INT') do
#   warn("\n#{caller.join("\n")}: interrupted")
#   # exit 1
# end

# Invoke the CLI
boot_module = BOOT_MODULE.to_s.underscore.upcase
invoked_from_new_generator = ARGV[0].eql?('new')
in_test_mode = ENV["#{boot_module}_ENV"].eql?('test')
skip_controller_start = invoked_from_new_generator || in_test_mode

unless skip_controller_start
  add_args = ARGV.size.positive? && ARGV.first.start_with?('-')
  ARGV.unshift('help') if ARGV.size.zero? || add_args
  begin
    # Order of precendence for the MainCommand class:
    # 1. defined in the application, 2. defined by a plugin exe or 3. the default
    # BOOT_MODULE = OneStack unless defined?(BOOT_MODULE)
    # BOOT_MODULE ||= SolidSupport unless defined?(BOOT_MODULE)
    cmd_object = defined?(MainCommand) ? MainCommand : BOOT_MODULE::MainCommand
    cmd_object.start
  rescue SolidSupport::Error => e
    puts e.message
   exit 1
  end
end
