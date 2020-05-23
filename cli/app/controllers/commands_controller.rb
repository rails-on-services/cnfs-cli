# frozen_string_literal: true

class CommandsController < Thor
  private

  def run(command_name, args = {})
    if options[:help]
      invoke(:help, [command_name.to_s])
      return
    end

    controller_class = "#{self.class.name.delete_suffix('Controller')}/#{command_name}_controller".camelize

    unless (controller = controller_class.safe_constantize)
      raise Error, set_color("Class not found: #{controller_class} (this is a bug. please report)", :red)
    end

    args = ::HashWithIndifferentAccess[args]
    # args = ::HashWithIndifferentAccess.new(options.slice(*options_to_args).merge(args))
    args = Thor::CoreExt::HashWithIndifferentAccess.new(options.slice(*options_to_args).merge(args))
    opts = Thor::CoreExt::HashWithIndifferentAccess.new(options.except(*options_to_args))

    # new_args = args.slice(*one_to_many)
    # new_args.transform_keys! { |key| "#{key}s" }
    # new_args.transform_values! { |value| [value] }
    # new_args = args.except(*one_to_many).merge(new_args)
    # args = Thor::CoreExt::HashWithIndifferentAccess.new(new_args)

    conn = controller.new(args, opts)
    raise Cnfs::Error, conn.error_messages unless conn.valid?

    conn.execute
  end

  def options_to_args
    %w[target_names target_name namespace_name application_name service_names service_name]
    # %w[context_name key_name target_name namespace_name application_name service_names profile_names tag_names]
  end

  # def one_to_many
  #   %w[target_name service_name]
  # end
end
