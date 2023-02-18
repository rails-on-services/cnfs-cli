# frozen_string_literal: true

module SolidRecord
  def self.one_stack = OneStack
end

module OneStack
  class << self
    def segments
      require_relative 'models'
      SolidRecord.setup
      SolidRecord.toggle_callbacks do
        root = SolidRecord::File.create(source: 'one_stack/config/segment.yml', content_format: :singular,
                                        model_class_name: 'OneStack::SegmentRoot')
        owner = root.segments.first.segments.first.model
        SolidRecord::DirGeneric.create(source: 'one_stack/segments', model_class_name: 'component', owner: owner,
                                       namespace: 'one_stack')
      end
    end
  end
end
