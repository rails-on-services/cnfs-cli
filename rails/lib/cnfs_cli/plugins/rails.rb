# frozen_string_literal: true

module CnfsCli
  module Plugins
    class Rails
      class << self
        def initialize_rails
          require 'cnfs_cli/rails'
          Cnfs.logger.info "[Rails] Initializing from #{gem_root}"
          ActiveSupport::Notifications.subscribe('on_runtime_switch.cli') { |_event| on_runtime_switch }
          ActiveSupport::Notifications.subscribe('set_compose_env.cli') do |event|
            set_compose_env(event.payload[:command], event.payload[:hash])
          end
        end

        def gem_root
          CnfsCli::Rails.gem_root
        end

        # NOTE: This is specific to a CNFS Rails project
        # Create a softlink in repo/services/.env to manifests dir so that iam.env, etc is available
        # rubocop:disable Metrics/AbcSize
        def on_runtime_switch
          return
          return unless Cnfs.project.repository&.services_path&.exist?

          services_path = Cnfs.project.repository.services_path
          Dir.chdir(services_path) do
            Cnfs.logger.info "Rails plugin configuring on runtime switch #{Dir.pwd}"
            FileUtils.rm_f('.env')
            path = Cnfs.project.path(from: services_path, to: :manifests)
            FileUtils.ln_s(path, '.env')
          end
        end
        # rubocop:enable Metrics/AbcSize

        def set_compose_env(command, hash)
          return unless command.run('docker ps').out.index('gem_server')

          gem_cache_server = if Cnfs.platform.darwin?
            # TODO: Make this configurable per user
            command.run('ifconfig vboxnet1').out.split[7]
          elsif Cnfs.platform.linux?
            command.run('ip -o -4 addr show dev docker0').out.split[3].split('/')[0]
          end
          hash.merge!('GEM_SERVER' => "http://#{gem_cache_server}:9292") if gem_cache_server
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
end
