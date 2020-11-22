# frozen_string_literal: true

#
# Modify a new Rails application or plugin (engine) into a CNFS service
def source_paths
  [views_path, views_path.join('templates'), lib_path, lib_path.join('templates'),
   core_path, core_path.join('templates')] + Array(super)
end

def views_path
  internal_path.join(ENV['CNFS_TYPE'])
end

def lib_path
  internal_path.join('lib')
end

def core_path
  internal_path.join('../lib')
end

def internal_path
  Pathname.new(__dir__)
end

apply('cnfs.rb')

# Start in the root of the project rather than spec/dummy if generating a plugin
work_dir = cnfs.type.eql?('plugin') ? '../..' : '.'
Dir.chdir(work_dir) do
  apply("#{internal_path}/#{cnfs.type}_generator.rb")
end
