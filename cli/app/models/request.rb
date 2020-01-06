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

  def last_service_name; args.service_names&.last end

  def service_names_to_s; service_names.join(' ') end

  def service_names; services.pluck(:name) end

  def services
    return (application.services + target.services) unless args.service_names

    application.services.where(name: args.service_names) + target.services.where(name: args.service_names)
  end

  # def resources
  #   application.resources.where(name: args.service_names) + target.resources.where(name: args.service_names)
  # end
end
