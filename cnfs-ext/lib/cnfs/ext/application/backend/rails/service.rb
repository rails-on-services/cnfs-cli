# frozen_string_literal: true

module Cnfs::Ext
  module Application::Backend
    class Rails::Service < Cnfs::Core::Concerns::Generator
      attr_accessor :values, :service, :config

      def setup
        @values = options[:values]
        @service = options[:service]
        @config = options[:config]
      end

      def environment_file
          # binding.pry
        if config.environment
          create_file("#{service_path}.env", "#{config.environment.to_env.join("\n")}\n")
      #   elsif File.exist?(env_file)
      #     remove_file(env_file)
        end
      end

      # Generate skaffold/compose manifest
      def manifest
        template("#{options.orchestrator}.yml.erb", "#{service_path}.yml")
      end

      def service_path; "#{values.path_for}/#{service}" end

      private

      def a_path; __dir__ end
      def gem_root; Cnfs::Ext.gem_root end

      def is_cnfs_service; config.ros end
      def has_envs; !config.environment.nil? end
      def env_files
        ary = []
        ary.append('../platform.env')
        ary.append("../rails/#{service}.env") if has_envs
        ary
      end

      def use_cnfs_context_dir; (not values.is_cnfs? and config.ros) end
      def context_dir; use_cnfs_context_dir ? 'ROS_CONTEXT_DIR' : 'CONTEXT_DIR' end
      def mount_cnfs; (not values.is_cnfs? and not config.ros) end
      def build_args; values.config.dig(:image, :build_args) || {} end

      # Compose only
      def compose_version; values.config.compose.version end

      # def tag; config&.tag || 'latest' end
      # def repository; config&.repository || name end
      # def profile; config&.profile || name end
      # def ports; config&.ports || [] end
      # # NOTE: Update image_type
      # def image; Stack.config.platform.config.images.rails end
      # def profiles; config&.profiles || [] end


      # skaffold only methods
      def skaffold_version; values.config.skaffold.version end
      def context_path; "#{relative_path}#{config.ros ? '/ros' : ''}" end
      def relative_path; @relative_path ||= ('../' * values.path_for.to_s.split('/').size).chomp('/') end
      # NOTE: from skaffold v0.36.0 the dockerfile_path is relative to context_path
      # leaving this in in case the behvior reverts back
      # def dockerfile_path; "#{relative_path}/#{config.ros ? 'ros/' : ''}Dockerfile" end
      def dockerfile_path; 'Dockerfile' end
      def pull_policy; 'Always' end
      # TODO: get the pull secret sorted
      def pull_secret; 'test' end
      # def pull_secret; Stack.registry_secret_name end
      def secrets_files; has_envs ? [:platform, @service.to_sym] : %i(platform) end
      def metrics_enabled
        values.settings.dig(:environment, :platform, :metrics, :enabled)
      end

      # TODO: This will be true if backend settings has kafkaconnect.config.enabled; make sure this is the correct test
      def kafka_schema_registry_enabled
        values.parent.settings.dig(:"kafka-schema-registry", :config, :enabled)
      end
    end
  end
end
