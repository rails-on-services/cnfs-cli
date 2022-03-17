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
      SolidRecord::DataStore.load(*config.solid_record.load_paths)
      SolidRecord.tables.select { |t| t.respond_to?(:after_load) }.each(&:after_load)
    end

    class << self
      def gem_root() = OneStack.gem_root
    end
  end
end
