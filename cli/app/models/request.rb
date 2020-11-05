# frozen_string_literal: true

class Request
=begin
  include ActiveModel::Model
  include ActiveModel::Validations

  # Attributes set on initialization
  attr_accessor :args, :options, :output, :command, :response
  # :command_module :command_group, :command_name, :command_object

  # Attributes derived from base + args
  attr_accessor :targets, :services, :resources

  # Attributes accessed by controllers, runtimes, etc
  attr_accessor :deployment, :target, :runtime, :namespace, :application, :service
  attr_accessor :base, :selected_services

  validate :members

  def initialize(attributes = {})
    super
    @base = Context.find_or_initialize_by(name: ENV['CNFS_CONTEXT'] || options.context_name)
    @response = Response.new(command_name: command.name, options: options, output: output,
                             command: command.object, errors: Cnfs::Errors.new)
    send("initialize_#{command.group}")
  end

  def members
    send("validate_#{command.group}")
  end

  ###
  # Service Manifest
  ###
  def initialize_service_manifest
    @targets = args.target_names ? Target.where(name: args.target_names) : base.targets
    @namespace = args.namespace_name ? Namespace.find_by(name: args.namespace_name) : base.namespace
    @application = args.application_name ? Application.find_by(name: args.application_name) : base.application
    return unless namespace && application

    @deployment = Deployment.find_by(application: application, namespace: namespace)
  end

  def validate_service_manifest
    errors.add(:namespace, 'Invalid') unless namespace
    errors.add(:application, 'Invalid') unless application
    errors.add(:deployment, 'Not found') unless deployment
    errors.add(:targets, 'Invalid') unless targets.any?

    targets.each do |target|
      errors.add(:target, 'Invalid or missing') unless namespace&.targets&.include?(target)
    end
  end

  ###
  # Image Operations
  ###
  def initialize_image_operations
    @target = args.target_name ? Target.find_by(name: args.target_name) : base.targets.first
    @namespace = args.namespace_name ? Namespace.find_by(name: args.namespace_name) : base.namespace
    @application = args.application_name ? Application.find_by(name: args.application_name) : base.application
    @deployment = Deployment.find_by(application: application, namespace: namespace)
  end

  def validate_image_operations
    errors.add(:namespace, 'Invalid') unless namespace
    errors.add(:application, 'Invalid') unless application
    errors.add(:target, 'Invalid or missing') unless target && namespace.targets.include?(target)
    errors.add(:deployment, 'Invalid or missing') unless deployment
    return unless errors.empty?

    configure_target(target)
    @selected_services = args.service_name ? Service.where(name: args.service_name) : application.services # .first
    # errors.add(:service, 'Invalid') unless service and application.services.include?(service)
  end

  ###
  # Cluster Admin
  ###
  def initialize_cluster_admin
    @targets = args.target_names ? Target.where(name: args.target_names) : base.targets
    @namespace = args.namespace_name ? Namespace.find_by(name: args.namespace_name) : base.namespace
    # Application needed to calculate the compose project name
    @application = args.application_name ? Application.find_by(name: args.application_name) : base.application
  end

  def validate_cluster_admin
    errors.add(:namespace, 'Invalid') unless namespace
    errors.add(:application, 'Invalid') unless application

    targets.each do |target|
      errors.add(:target, 'Invalid or missing') unless namespace&.targets&.include?(target)
    end
  end

  ###
  # Cluster Runtime
  ###
  def initialize_cluster_runtime
    @targets = args.target_names ? Target.where(name: args.target_names) : base.targets
    @namespace = args.namespace_name ? Namespace.find_by(name: args.namespace_name) : base.namespace
    # Application needed to calculate the compose project name
    @application = args.application_name ? Application.find_by(name: args.application_name) : base.application
  end

  def validate_cluster_runtime
    errors.add(:namespace, 'Invalid') unless namespace
    errors.add(:application, 'Invalid') unless application

    targets.each do |target|
      errors.add(:target, 'Invalid or missing') unless namespace&.targets&.include?(target)
    end
  end

  ###
  # Service Admin
  # start, restart, stop, terminate
  ###
  def initialize_service_admin
    @targets = args.target_names ? Target.where(name: args.target_names) : base.targets
    @namespace = args.namespace_name ? Namespace.find_by(name: args.namespace_name) : base.namespace
    @application = args.application_name ? Application.find_by(name: args.application_name) : base.application
    @deployment = Deployment.find_by(application: application, namespace: namespace)
  end

  def validate_service_admin
    errors.add(:namespace, 'Invalid') unless namespace
    errors.add(:application, 'Invalid') unless application
    # errors.add(:target, 'Invalid or missing') unless target and namespace.targets.include?(target)

    targets.each do |target|
      errors.add(:target, 'Invalid or missing') unless namespace&.targets&.include?(target)
    end
    return unless errors.empty?

    # configure_target(target)
    @services = args.service_names ? Service.where(name: args.service_names) : base.services # .first
    # @selected_services = args.service_name ? Service.where(name: args.service_name) : application.services # .first
  end

  ###
  # Service Runtime
  ###
  def initialize_service_runtime
    return if command.name.eql?(:console) && args.service_name.nil?

    @target = args.target_name ? Target.find_by(name: args.target_name) : base.targets.first
    @namespace = args.namespace_name ? Namespace.find_by(name: args.namespace_name) : base.namespace
    @application = args.application_name ? Application.find_by(name: args.application_name) : base.application
    @service = args.service_name ? Service.find_by(name: args.service_name) : base.services.first
  end

  def validate_service_runtime
    return if command.name.eql?(:console) && args.service_name.nil?

    errors.add(:namespace, 'Invalid') unless namespace
    errors.add(:target, 'Invalid or missing') unless target && namespace.targets.include?(target)
    errors.add(:application, 'Invalid') unless application
    errors.add(:service, 'Invalid') unless service
    return if errors.any?

    configure_target(target)
  end

  ###
  # Controller accessed methods
  ###
  def each_target
    # binding.pry
    targets.each do |current_target|
      configure_target(current_target)
      output.puts "Running in #{target.exec_path}" if options.debug
      Dir.chdir(target.exec_path) do
        yield target
      end
      clean_target
    end
  end

  def configure_target(current_target)
    @target = current_target
    @target.context = self
    @runtime = command.module.eql?('targets') ? target.infra_runtime : target.runtime
    @runtime.context = self
    @runtime.response = response
    @selected_services = (application&.services || []) + target.services
    # binding.pry
    output.puts "selected services: #{selected_services.pluck(:name)}" if options.debug
    set_encryption_key if deployment
  end

  def clean_target
    @target = nil
    @selected_services = nil
    # @response = nil
    @runtime = nil
  end

  def set_encryption_key
    Cnfs.key = deployment.key&.name
    if Cnfs.key
      output.puts "encryption key set to '#{Cnfs.key.name}'" if options.verbose || options.debug
    else
      output.puts "WARN: encryption key not found for key name '#{Cnfs.key}'"
    end
  end

  def runtime_generator_class
    runtime.generator_class
  end

  def write_path(type = :deployment)
    Cnfs.application.root.join('.cnfs').join(path_for(type))
  end

  def path_for(type)
    case type
    when :deployment
      "tmp/cache/#{project_name_attrs.join('/')}"
    when :infra
      "data/infra/#{target.name}"
    when :runtime
      "tmp/runtime/#{project_name_attrs.join('/')}"
    end
  end

  def project_name
    project_name_attrs.join('_')
  end

  def project_name_attrs
    [target.name, namespace.name, application.name]
  end
=end
end

#   def target_services
#     result = target.services
#     result = result.where(name: args.service_names) unless args.service_names.empty?
#     result = result.joins(:tags).where(tags: { name: args.tag_names }) unless args.tag_names.empty?
#     result
#   end

# def resources
#   application.resources.where(name: args.service_names) + target.resources.where(name: args.service_names)
# end
