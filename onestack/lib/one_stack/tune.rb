# frozen_string_literal: true

module OneStack
  class << self
    def gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')

    # TODO: Finish refactor
    def segment(name)
      path = segments_path.join(name)
      return path if path.exist?
    end

    def segments() = @segments ||= segments_path.glob('**/*').select(&:directory?)

    # TODO: Extension needs to define a path as gem_root is only available in Plugins
    def segments_path() = root.join('segments')
  end

  class Tune < Hendrix::Tune
    # initializer 'setup data_store' do |app|
    #   SolidRecord::DataStore.load # add_models(Hendrix::Core.model_names)
    #   Hendrix.data_store.setup # if data_store
    # end

    initializer 'node load' do |app|
      # SegmentRoot.load
      # Hendrix.with_timer('load nodes') { SegmentRoot.load }
    end unless ENV['HENDRIX_CLI_ENV'].eql?('test')

    class << self
      def gem_root() = OneStack.gem_root
    end

    config.after_initialize do |config|
      binding.pry
      config.paths.segments = 'segments'
      config.paths.src = 'src'
    end
  end
end
