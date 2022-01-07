# frozen_string_literal: true

require 'pathname'

SPEC_DIR = Pathname.new(__dir__)

plugin_path = SPEC_DIR.join('../../cnfs/lib')
$:.unshift(plugin_path)

require 'cnfs/spec_loader'
