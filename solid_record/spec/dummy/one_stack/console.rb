# frozen_string_literal: true

module SolidRecord
  def self.one_stack = OneStack
end

module OneStack
  class << self
    def one_stack = segments(Pathname.new(__dir__).join('../../../../onestack/spec/dummy'))
    def segments(srp = Pathname.new(__dir__))
      require_relative 'models'
      SolidRecord.setup
      SolidRecord.toggle_callbacks do
        root = SolidRecord::File.create(source: srp.join('config/segment.yml'), content_format: :singular,
                                        model_class_name: 'OneStack::SegmentRoot')
        owner = root.segments.first.segments.first.model
        SolidRecord::DirGeneric.create(source: srp.join('segments'), model_class_name: 'component', owner: owner,
                                       namespace: 'one_stack')
      end
    end
  end
end
