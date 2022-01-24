# frozen_string_literal: true

require 'pathname'

# Determine if cwd is inside an app or not
path = Pathname.new(Dir.pwd).ascend { |path| break path if path.join(ROOT_FILE_ID).file? }

# If cwd is inside an app then load the framework and run the CLI
if path
  APP_CWD = Pathname.new(Dir.pwd)
  APP_ROOT = path
  Dir.chdir(APP_ROOT) { require 'hendrix/app_loader' }
else
    binding.pry
  require 'hendrix/no_app_loader'
end
