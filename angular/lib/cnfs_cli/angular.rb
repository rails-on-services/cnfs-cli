# frozen_string_literal: true

require 'cnfs_cli/angular/version'

module CnfsCli
  module Angular
    class << self
      def gem_root
        @gem_root ||= Pathname.new(__dir__).join('../..')
      end

      def initialize
        Cnfs.logger.info "[Angular] Initializing from #{gem_root}"
      end

      def customize
        src = gem_root.join('app/generators/rails')
        dest = Cnfs.paths.lib.join('generators/rails')
        FileUtils.rm_rf(dest)
        FileUtils.mkdir_p(dest)
        %w[service lib].each do |node|
          FileUtils.cp_r(src.join(node), dest)
        end
      end
    end
  end
end
