# frozen_string_literal: true

# .pryrc

# SolidRecord.glob_pattern = '*.yml'
# SolidRecord.path_column = 'sr_path'
# SolidRecord.key_column = 'sr_key'
# SolidRecord.reference_suffix = 'other'

if defined? SolidRecord
  %w[blog stack infra].each do |what|
    %w[file monolith hybrid].each do |type| # rubocop:disable Performance/CollectionLiteralInLoop
      define_method "#{what}_#{type}" do
        base_path = Pathname.new('spec/dummy').join(what)
        base_path.join('app/models').glob('*.rb').each { |path| require_relative(path) }
        # SolidRecord::DataStore.load(base_path.join('data', "#{type}-array/groups.yml"))
        file = base_path.join('data', "#{type}-array/groups.yml")
        tempdir = Pathname.new(Dir.mktmpdir)
        FileUtils.cp_r(file.parent, tempdir)
        path = tempdir.join(file.parent.basename, file.basename)
        # Element.create_from_path(path)
        SolidRecord::DataStore.load(path)
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
  SolidRecord.config.encryption_key = 'c0adafa60b624f300fe976a835e78bed7dcc15261c6250d021a5c3af86469213'

  # infra_monolith

  def g() = @g ||= Group.last
  def h() = @h ||= Host.last
  def s() = @s ||= Service.last

  def hu() = h.update(port: h.port + 1)
end
