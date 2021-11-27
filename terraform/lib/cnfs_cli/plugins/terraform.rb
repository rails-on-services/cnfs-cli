# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Terraform
      class << self
        def initialize_terraform
          require 'cnfs_cli/terraform'
          Cnfs.logger.info "[Terraform] Initializing from #{gem_root}"
        end

        # def customize
        #   src = gem_root.join('app/generators/terraform')
        #   dest = Cnfs.paths.lib.join('generators/terraform')
        #   FileUtils.rm_rf(dest)
        #   FileUtils.mkdir_p(dest)
        #   %w[service lib].each do |node|
        #     FileUtils.cp_r(src.join(node), dest)
        #   end
        # end

        def gem_root
          # {CnfsCli::Terraform.gem_root
          CnfsCli::Terraform.gem_root
        end
      end
    end
  end
end
