# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Native
      class << self
        def initialize_native
          require 'cnfs_cli/native'
          Cnfs.logger.info "[Native] Initializing from #{gem_root}"
        end

        # def customize
        #   src = gem_root.join('app/generators/native')
        #   dest = Cnfs.paths.lib.join('generators/native')
        #   FileUtils.rm_rf(dest)
        #   FileUtils.mkdir_p(dest)
        #   %w[service lib].each do |node|
        #     FileUtils.cp_r(src.join(node), dest)
        #   end
        # end

        def gem_root
          CnfsCli::Native.gem_root
        end
      end
    end
  end
end
