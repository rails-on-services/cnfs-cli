# frozen_string_literal: true

# .pryrc

# SolidRecord.glob_pattern = '*.yml'
# SolidRecord.path_column = 'sr_path'
# SolidRecord.key_column = 'sr_key'
# SolidRecord.reference_suffix = 'baby'
# SolidRecord.parser = :yaml

def blog
  Pathname.new('.').glob('spec/dummy/blog/app/models/*.rb').each { |path| require_relative path }
  SolidRecord.path_maps = [{ path: 'spec/dummy/blog/data' }]
  SolidRecord.load
end

def infra
  Pathname.new('.').glob('spec/dummy/infra/app/models/*.rb').each { |path| require_relative path }
  SolidRecord.path_maps = [{ path: 'spec/dummy/infra/data' }]
  SolidRecord.path_map = SolidRecord::MyPathMap
  SolidRecord.load
end

def stack
  Pathname.new('.').glob('spec/dummy/stack/app/models/*.rb').each { |path| require_relative path }
  SolidRecord.path_maps = [{ path: 'spec/dummy/stack/data', map: './segments', recursive: true }]
  SolidRecord.load
end
