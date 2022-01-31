# frozen_string_literal: true

require 'pathname'

SPEC_DIR = Pathname.new(__dir__)

git_path = SPEC_DIR.join('../../.git')

if File.exist?(git_path)
  plugin_path = SPEC_DIR.join('../../hendrix/lib')
  $:.unshift(plugin_path)
end
