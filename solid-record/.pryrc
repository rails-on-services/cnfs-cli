# frozen_string_literal: true

# .pryrc

# SolidRecord.glob_pattern = '*.yml'
# SolidRecord.path_column = 'sr_path'
# SolidRecord.key_column = 'sr_key'
# SolidRecord.reference_suffix = 'other'

def path_map(what)
  {
    blog: 'users/blogs/posts',
    infra: '.',
    stack: 'segments'
  }[what]
end

%i[blog stack infra].each do |what|
  %i[file monolith hybrid].each do |type|
    define_method "#{what}_#{type}" do |_path_map = '.', recurse = false|
      Pathname.new('.').glob("spec/dummy/#{what}/app/models/*.rb").each { |path| require_relative(path) }
      # Pathname.new('.').glob('../core/app/models/*.rb').each { |path| require_relative path }
      SolidRecord::DataStore.load
      SolidRecord::DataPath.create(path: "spec/dummy/#{what}/data/#{type}", path_map: path_map(what), recurse: recurse)
    end
  end
end

def srd() = SolidRecord::Document

def sre() = SolidRecord::Element

def srp() = SolidRecord::DataPath
