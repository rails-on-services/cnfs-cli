# frozen_string_literal: true

class CommandsController < Thor

  private

  def run(command_name, args = {}, one_service = false)
    if options[:help]
      invoke(:help, [command_name.to_s])
      return
    end

    args = Thor::CoreExt::HashWithIndifferentAccess.new(args.merge(options.slice(*options_to_args)))
    if one_service and not args.service_names&.size&.eql?(1)
      raise Error, set_color('one service name is required', :red)
    end

    # TODO: maybe grab deployment from ~/.config/cnfs/project/project.yml
    # If so, then Cnfs module should load that file if it exists and surface the values

    controller_class = "#{self.class.name.gsub('Controller', '')}::#{command_name.to_s.camelize}Controller"
    unless (controller = controller_class.safe_constantize)
      raise Error, set_color("Class not found: #{controller_class} (this is a bug. please report)", :red)
    end

    controller.new(args, Thor::CoreExt::HashWithIndifferentAccess.new(options.except(*options_to_args))).call
  end

  # defaults = Thor::CoreExt::HashWithIndifferentAccess.new(default)
  # binding.pry

  # def default
  #   {
  #     deployment: default_deployment,
  #     application: default_deployment.application,
  #     target: default_deployment.targets.find_by(name: :default) || default_deployment.targets.first
  #   }
  # end

  # def default_deployment; @default_deployment ||= Deployment.find_by(name: :default) || Deployment.first end

  def options_to_args
    %w[deployment_name target_name application_name service_names]
  end

  def params(method_name, method_binding)
    method(method_name).parameters.each_with_object({}) do |(_, name), hash|
      hash[name] = method_binding.local_variable_get(name)
    end
  end
end
