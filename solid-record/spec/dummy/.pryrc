# frozen_string_literal: true

# .pryrc

# SolidRecord.glob_pattern = '*.yml'
# SolidRecord.path_column = 'sr_path'
# SolidRecord.key_column = 'sr_key'
# SolidRecord.reference_suffix = 'baby'
# SolidRecord.parser = :yaml

# def lc() = SolidRecord.configure(schema_paths: 'app/models', data_paths: { path: 'data', map: { '.' => 'segments' } }).load

#    map: { '.' => 'stacks', 'stacks' => 'environments', 'stacks/environments' => 'targets' }

def lc() = SolidRecord.configure(schema_paths: 'app/models', data_paths: SolidRecord::PathMap.new(path: 'data')).load
