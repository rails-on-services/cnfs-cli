# frozen_string_literal: true

class Request
  attr_accessor :deployment, :target, :args, :options

  def initialize(deployment, target, args, options)
    @deployment = deployment
    @target = target
    @args = args
    @options = options
  end

  def last_service_name; args.last if args.any? end

  def service_names; services.pluck(:name) end

  def service_names_to_s; service_names.join(' ') end

  def services
    if options.layer
      layer = deployment.application.layers.find_by(name: options.layer) || target.layers.find_by(name: options.layer) 
      return layer.services
    end
    deployment.application.services.where(name: args) + target.services.where(name: args)
  end

  # def layers
  #   @layers ||= (deployment.application.layers + target.layers)
  # end

  # def services
  #   @services ||= (deployment.application.services + target.services)
  # end

  # def resources
  #   @resources ||= (deployment.application.resources + target.resources)
  # end
end
