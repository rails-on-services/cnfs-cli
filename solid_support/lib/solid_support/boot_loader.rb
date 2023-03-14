# frozen_string_literal: true

require 'pathname'
require 'solid_support'

# End: this should move to somewhere else
load_path = Pathname.new(__dir__).join('../../app')
SolidSupport.add_loader(name: :solid_support, path: load_path)
SolidSupport.load_all
# End: this should move to somewhere else

BOOT_MODULE = SolidSupport unless defined?(BOOT_MODULE)
boot_module = BOOT_MODULE.to_s.underscore.upcase

git_path = Pathname.new(__dir__).join('../../../.git')
ENV["#{boot_module}_ENV"] ||= git_path.exist? ? 'development' : 'production'

ROOT_FILE_ID = 'config/environment.rb'

# Determine if cwd is inside an app or not
app_path = Pathname.new(Dir.pwd).ascend { |path| break path if path.join(ROOT_FILE_ID).file? }

# If cwd is inside an app then load the app and run the CLI
# Otherwise load the framework
# binding.pry
if app_path
  APP_CWD = Pathname.new(Dir.pwd)
  APP_ROOT = app_path
  Dir.chdir(APP_ROOT) { require 'solid_support/app_loader' }
else
  require 'solid_support/framework_loader'
end
