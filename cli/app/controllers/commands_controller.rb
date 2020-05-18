# frozen_string_literal: true

class CommandsController < Thor
  private

  def run(command_name, args = {}, _limits = {})
    if options[:help]
      invoke(:help, [command_name.to_s])
      return
    end

    unless (controller = controller_class(command_name))
      raise Error, set_color("Class not found: #{controller_class} (this is a bug. please report)", :red)
    end

    args = Thor::CoreExt::HashWithIndifferentAccess.new(args.merge(options.slice(*options_to_args)))
    opts = Thor::CoreExt::HashWithIndifferentAccess.new(options.except(*options_to_args))
    Cnfs.context_name = args.context_name
    controller.new(args, opts).call
  end

  def controller_class(command)
    "#{self.class.name.gsub('Controller', '')}::#{command.to_s.camelize}Controller".safe_constantize
  end

  def options_to_args
    %w[context_name key_name target_name namespace_name application_name service_names profile_names tag_names]
  end
end
