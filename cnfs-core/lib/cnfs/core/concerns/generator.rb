# frozen_string_literal: true

module Cnfs::Core::Concerns
  class Generator < Thor::Group
    include Thor::Actions

    attr_accessor :values, :service, :config

    def setup
      @values = options[:values]
      @config = options[:config]
    end

    private

    def source_paths; [user_path, a_path, internal_path] end
    def user_path; options.project_dir.join(a_path.to_s.gsub("#{gem_root}/", '')).join('templates').to_s end
    def internal_path; "#{a_path}/templates" end

    def expose_ports(port)
      port, proto = port.to_s.split('/')
      host_port = map_ports_to_host ? "#{port}:" : ''
      proto = proto ? "/#{proto}" : ''
      "\"#{host_port}#{port}#{proto}\""
    end

    def map_ports_to_host; false end

    def orchestrator; options.orchestrator end

    # Compose only
    def compose_version; values.config.compose.version end

    def compose_labels
      labels.select { |k, v| v }.map { |key, value| "#{key}: #{value}" }.join("\n      ")
    end

    # Skaffold only
    def skaffold_version; values.config.skaffold.version end
 
    def skaffold_labels(space_count = 12)
      labels.select { |k, v| v }.map { |key, value| "cnfs.io/#{key.to_s.gsub('_', '-')}: #{value}" }.join("\n#{' ' * space_count}")
    end

 
    # New Stuff from now
    def relative_path; @relative_path ||= ('../' * values.path_for.to_s.split('/').size).chomp('/') end

    def labels
      {
        platform_name: values.config.name,
        platform_env: values.config.env,
        platform_profile: values.config.profile,
        platform_feature_set: values.config.feature_set,
        platform_partition: :application,
        platform_component: :backend,
        platform_resource: options.service
      }
    end

    # TODO: Should be either services.env or platform.env
    def env_files; @env_files ||= ['../services.env'] end

=begin
      def is_cnfs_service; config.ros end
      def has_envs; !config.environment.nil? end
      def env_files
        ary = []
        ary.append('../platform/platform.env')
        ary.append("../platform/#{service}.env") if has_envs
        ary
      end

      def use_cnfs_context_dir; (not values.is_cnfs? and config.ros) end
      def context_dir; use_cnfs_context_dir ? 'ROS_CONTEXT_DIR' : 'CONTEXT_DIR' end
      def mount_cnfs; (not values.is_cnfs? and not config.ros) end
      def build_args; values.config.dig(:image, :build_args) || {} end


      # def tag; config&.tag || 'latest' end
      # def repository; config&.repository || name end
      # def profile; config&.profile || name end
      # def ports; config&.ports || [] end
      # # NOTE: Update image_type
      # def image; Stack.config.platform.config.images.rails end
      # def profiles; config&.profiles || [] end


      # skaffold only methods
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
=end
  end
end
