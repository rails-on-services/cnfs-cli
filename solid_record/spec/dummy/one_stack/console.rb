# frozen_string_literal: true

module OneStack
  class << self
    def config = @config ||= set_config

    def set_config
      config = ActiveSupport::OrderedOptions.new
      config.asset_names = %w[operators providers provisioners resources repositories]
      config
    end

    def c = Component
    def co = Context
  end
end

module SolidRecord
  class << self
    def os = OneStack

    def one_stack
      Pathname.new('one_stack/models/concerns').glob('*.rb').each { |p| require p.realpath }
      Pathname.new('one_stack/models').glob('*.rb').each { |p| require p.realpath }
      setup
      SolidRecord.toggle_callbacks do
        root = File.create(source: 'one_stack/config/segment.yml', model_class_name: 'OneStack::SegmentRoot',
                           content_format: :singular)
        owner = root.segments.first.segments.first.model
        DirGeneric.create(source: 'one_stack/segments', model_class_name: 'Component', owner: owner,
                          namespace: 'one_stack')
      end
    end
  end
end
