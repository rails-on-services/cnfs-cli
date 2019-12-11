# frozen_string_literal: true

class Service::RailsGenerator < ServiceGenerator
  def manifest
    template("service/rails/#{orchestrator}.yml.erb", "#{write_path}/#{service.name}.yml")
  end

  private

  def is_cnfs_service; service.ros end

  def mount; target.mount end
  # TODO: rework the project related methods in Cnfs::Core::Platform
  # def use_cnfs_context_dir; (not Cnfs::Core.is_cnfs? and service.ros) end
  def use_cnfs_context_dir; (is_cnfs_service) end

  def context_dir; use_cnfs_context_dir ? 'ROS_CONTEXT_DIR' : 'CONTEXT_DIR' end
  # def mount_cnfs; (not values.is_cnfs? and not service.ros) end
  def mount_cnfs; (is_cnfs_service) end

  # TODO: What about when build args are not available?
  def build_args
    @build_args ||= service.images[deployment.image_environment]['build_args']
  end

  # Skaffold Only
  # def relative_path; @relative_path ||= ('../' * values.path_for.to_s.split('/').size).chomp('/') end
  def relative_path; @relative_path ||= ('../' * write_path.split('/').size).chomp('/') end

  # def tag; config&.tag || 'latest' end
  # def repository; config&.repository || name end
  # def profile; config&.profile || name end
  # def ports; config&.ports || [] end
  # # NOTE: Update image_type
  # def image; Stack.config.platform.config.images.rails end
  # def profiles; config&.profiles || [] end


  # skaffold only methods
  def context_path; "#{relative_path}#{service.ros ? '/ros' : ''}" end
  def dockerfile_path; 'Dockerfile' end
  # def pull_policy; 'Always' end
  # def relative_path; @relative_path ||= ('../' * values.path_for.to_s.split('/').size).chomp('/') end
  # NOTE: from skaffold v0.36.0 the dockerfile_path is relative to context_path
  # leaving this in in case the behvior reverts back
  # def dockerfile_path; "#{relative_path}/#{config.ros ? 'ros/' : ''}Dockerfile" end
  # TODO: get the pull secret sorted
  def pull_secret; 'test' end
  # def pull_secret; Stack.registry_secret_name end
  def secrets_files; has_envs ? [:platform, service.name.to_sym] : %i(platform) end
  def metrics_enabled
    # TODO: should not know about layer, just check self (service) .environment
    layer.environment.dig(:platform, :metrics, :enabled)
  end

  # TODO: This will be true if backend settings has kafkaconnect.config.enabled; make sure this is the correct test
  def kafka_schema_registry_enabled
    layer.environment.dig(:"kafka-schema-registry", :config, :enabled)
  end
end
