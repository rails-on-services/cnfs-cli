# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Gcp
      class << self
        def initialize_gcp
          require 'cnfs_cli/gcp'
          Cnfs.logger.info "[Gcp] Initializing from #{gem_root}"
        end

        def gem_root
          CnfsCli::Gcp.gem_root
        end
      end
    end
  end
end
