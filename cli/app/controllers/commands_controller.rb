# frozen_string_literal: true

class CommandsController < Thor

  private

  def run(command_name, args = {}, limits = {})
    if options[:help]
      invoke(:help, [command_name.to_s])
      return
    end

    args = Thor::CoreExt::HashWithIndifferentAccess.new(args.merge(options.slice(*options_to_args)))
    check_limits(limits, args) if limits.any?

    controller_class = "#{self.class.name.gsub('Controller', '')}::#{command_name.to_s.camelize}Controller"
    unless (controller = controller_class.safe_constantize)
      raise Error, set_color("Class not found: #{controller_class} (this is a bug. please report)", :red)
    end
    controller.new(args, Thor::CoreExt::HashWithIndifferentAccess.new(options.except(*options_to_args))).call
  end

  def check_limits(limits, args)
    limits.each_pair do |name, size|
      raise Error, set_color("#{name} must be exactly #{size}", :red) if args[name] and args[name].size != size
    end
  end

  def options_to_args
    %w[deployment_name target_name application_name service_names]
  end

  def params(method_name, method_binding)
    method(method_name).parameters.each_with_object({}) do |(_, name), hash|
      hash[name] = method_binding.local_variable_get(name)
    end
  end
end
