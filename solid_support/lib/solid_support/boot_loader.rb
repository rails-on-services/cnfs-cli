# frozen_string_literal: true

git_path = File.expand_path('../../../.git', __dir__)

if File.exist?(git_path)
  ENV['HENDRIX_CLI_ENV'] ||= 'development'
  require 'pry'
end

ENV['HENDRIX_CLI_ENV'] ||= 'production'

require 'pathname'

ROOT_FILE_ID = 'config/environment.rb'

# Determine if cwd is inside an app or not
app_path = Pathname.new(Dir.pwd).ascend { |path| break path if path.join(ROOT_FILE_ID).file? }

# If cwd is inside an app then load the framework and run the CLI
if app_path
  APP_CWD = Pathname.new(Dir.pwd)
  APP_ROOT = app_path
  Dir.chdir(APP_ROOT) { require 'solid_support/main_loader' }
else
  require 'solid_support/project_loader'
end
