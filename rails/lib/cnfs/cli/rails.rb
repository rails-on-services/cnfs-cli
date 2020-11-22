# frozen_string_literal: true

require 'cnfs/cli/rails/version'

module Cnfs
  module Cli
    module Rails
      class << self
        def gem_root
          @gem_root ||= Pathname.new(__dir__).join('../../..')
        end

        def initialize
          Cnfs.logger.info "Initializing plugin rails from #{gem_root}"
        end

        # NOTE: This is specific to a CNFS Rails project
        # Create a softlink in repo/services/.env to the write_path dir so that iam.env, etc is available
        # rubocop:disable Metrics/AbcSize
        def on_runtime_switch
          return unless Cnfs.project.repository&.services_path&.exist?

          Dir.chdir(Cnfs.project.repository.services_path) do
            Cnfs.logger.info "Rails plugin configuring on runtime switch #{Dir.pwd}"
            FileUtils.rm_f('.env')
            path = Dir.pwd
            r_path = Cnfs.project_root.x_relative_path_from(Cnfs.project_root.join(path)).join(Cnfs.project.write_path)
            return unless r_path.exist?

            FileUtils.ln_s(r_path, '.env')
          end
        end
        # rubocop:enable Metrics/AbcSize

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
end
