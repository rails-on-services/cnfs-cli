# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Angular
      class << self
        def initialize_angular
          require 'cnfs_cli/angular'
          Cnfs.logger.info "[Angular] Initializing from #{CnfsCli::Angular.gem_root}"
        end

        def customize
          src = CnfsCli::Angular.gem_root.join('app/generators/angular')
          dest = Cnfs.paths.lib.join('generators/angualr')
          FileUtils.rm_rf(dest)
          FileUtils.mkdir_p(dest)
          %w[service lib].each do |node|
            FileUtils.cp_r(src.join(node), dest)
          end
        end
      end
    end
  end
end
