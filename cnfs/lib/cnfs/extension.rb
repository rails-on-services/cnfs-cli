# frozen_string_literal: true
#
# Extensions provide a search path for segments

module Cnfs
  class << self
    def extensions() = @extensions ||= {}
  end

  class Extension
    class << self
      def segment(name)
        path = segments_path.join(name)
        return path if path.exist?
      end

      def segments() = @segments ||= segments_path.glob('**/*').select(&:directory?)

      # TODO: Extension needs to define a path as gem_root is only available in Plugins
      def segments_path() = root.join('segments')

      def inherited(base)
        name = name_from_base(base)
        return if base.to_s.eql?('Cnfs::Plugin')

        Cnfs.extensions[name] = base
      end

      # Return the module namespace from an Extension subclass
      #
      # Cnfs::Aws::Plugin => :aws
      # Test::Application => :application
      #
      def name_from_base(base) = base.name.to_s.split('::')[1].downcase.to_sym
    end
  end
end
