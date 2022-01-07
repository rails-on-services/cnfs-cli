# frozen_string_literal: true

module Cnfs
  module Docker
    class Plugin < Cnfs::Plugin
      class << self
        def initialize_docker
          require 'cnfs/docker'
          Cnfs.logger.info "[Docker] Initializing from #{gem_root}"
        end

        # def customize
        #   src = gem_root.join('app/generators/docker')
        #   dest = Cnfs.paths.lib.join('generators/docker')
        #   FileUtils.rm_rf(dest)
        #   FileUtils.mkdir_p(dest)
        #   %w[service lib].each do |node|
        #     FileUtils.cp_r(src.join(node), dest)
        #   end
        # end

        def gem_root
          #{CnfsCli::Docker.gem_root
          Cnfs::Docker.gem_root
        end
      end
    end
  end
end
