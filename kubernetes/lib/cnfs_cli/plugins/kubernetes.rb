# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Kubernete
      class << self
        def initialize_kubernetes
          require 'cnfs_cli/kubernetes'
          Cnfs.logger.info "[Kubernete] Initializing from #{gem_root}"
        end

        # def customize
        #   src = gem_root.join('app/generators/kubernetes')
        #   dest = Cnfs.paths.lib.join('generators/kubernetes')
        #   FileUtils.rm_rf(dest)
        #   FileUtils.mkdir_p(dest)
        #   %w[service lib].each do |node|
        #     FileUtils.cp_r(src.join(node), dest)
        #   end
        # end

        def gem_root
          #{CnfsCli::Kubernete.gem_root
          CnfsCli::Kubernete.gem_root
        end
      end
    end
  end
end
