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
  %i[file monolith hybrid].each do |type| # rubocop:disable Performance/CollectionLiteralInLoop
    define_method "#{what}_#{type}" do
      base_path = "spec/dummy/#{what}"
      Pathname.new('.').glob("#{base_path}/app/models/*.rb").each { |path| require_relative(path) }
      SolidRecord::DataStore.load_path("#{base_path}/data/#{type}-array")
    end
  end
end

def e() = SolidRecord::Element

def p() = SolidRecord::Path

def a() = SolidRecord::Association

def d() = SolidRecord::Document

def me() = SolidRecord::ModelElement

def re() = SolidRecord::RootElement

SolidRecord.logger.formatter = SolidRecord::ColorFormatter
SolidRecord.logger.level ||= :info
SolidRecord.config.raise_on_error = false

infra_monolith
