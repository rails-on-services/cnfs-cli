# frozen_string_literal: true

module OneStack
  class << self
    def gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')

    def plugins() = SolidSupport.plugins

    # TODO: Finish refactor
    def segment(name)
      path = segments_path.join(name)
      return path if path.exist?
    end

    def segments() = @segments ||= segments_path.glob('**/*').select(&:directory?)

    def segments_path() = gem_root.join('segments')
  end

  class Plugin < SolidSupport::Plugin
    config.after_initialize do |config|
      SolidRecord.setup
      SolidRecord.toggle_callbacks do
        # srp = Pathname.new(__dir__).join('../../../solid_record/spec/dummy/one_stack')
        root = SolidRecord::File.create(source: 'config/segment.yml', content_format: :singular,
                                        model_class_name: 'OneStack::SegmentRoot')
        # root = SolidRecord::File.create(source: srp.join('config/segment.yml').to_s, content_format: :singular,
        owner = root.segments.first.segments.first.model
        SolidRecord::DirGeneric.create(source: 'segments', model_class_name: 'component', owner: owner,
                                       namespace: 'one_stack')
      # SolidRecord::DirGeneric.create(source: srp.join('segments').to_s, model_class_name: 'component', owner: owner,
      end
      SolidRecord.tables.select { |t| t.respond_to?(:after_load) }.each(&:after_load)
    end

    class << self
      def gem_root() = OneStack.gem_root
    end
  end
end
