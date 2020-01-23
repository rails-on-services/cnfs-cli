# frozen_string_literal: true

class Request
  attr_accessor :deployment, :target, :application, :args, :options

  def initialize(deployment, args, options)
    @deployment = deployment
    @target = deployment.target
    @application = deployment.application
    @args = args
    @options = options
  end

  def last_service_name
    args.service_names&.last
  end

  def service_names_to_s
    service_names.join(' ')
  end

  def service_names
    services.pluck(:name)
  end

  def services
    @services ||= application_services + target_services
  end

  def application_services
    result = application.services
    result = result.where(name: args.service_names) unless args.service_names.empty?
    result = result.joins(:tags).where(tags: { name: args.tag_names }) unless args.tag_names.empty?
    result
  end

  def target_services
    result = target.services
    result = result.where(name: args.service_names) unless args.service_names.empty?
    result = result.joins(:tags).where(tags: { name: args.tag_names }) unless args.tag_names.empty?
    result
  end

  # def resources
  #   application.resources.where(name: args.service_names) + target.resources.where(name: args.service_names)
  # end
end
