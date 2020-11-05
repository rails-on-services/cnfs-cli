# frozen_string_literal: true

class CommandsController < Thor
  private

  # NOTE: Any command using run to invoke must require the full project
  # i.e. this is not for %w[version help new init]
  def run(command_name, arguments = {})
    if options.help
      invoke(:help, [command_name.to_s])
      return
    end

    Cnfs.require_deps
    arguments = Thor::CoreExt::HashWithIndifferentAccess.new(arguments)
    response = Response.new(command_name: command_name, options: options, output: $stdout, input: $stdin)
    if not Cnfs.require_project!(arguments: arguments, options: options, response: response)
      # binding.pry
      raise Cnfs::Error, set_color('Not a cnfs project', :red)
    end

    Cnfs.project.initialize!
    puts Cnfs.config.to_hash if options.debug.positive?
    # TODO: Some way to filter out the services that need to be built rather than all services (pg, nginx, etc)
    # NOTE: This could also apply to resources or anything else that uses -a
    if options.all
      arguments[:services] = Service.pluck(:name) if arguments.key?(:services) and arguments[:services].empty?
      arguments[:service] = arguments[:services].last if arguments.key?(:service) and arguments[:service].nil?
      Cnfs.project.initialize!
    end
    raise Cnfs::Error, Cnfs.project.errors.full_messages.join("\n") unless Cnfs.project.valid?

    controller_name = "#{self.class.name.delete_suffix('Controller')}/#{command_name}_controller".camelize

    unless (controller_class = controller_name.safe_constantize)
      raise Cnfs::Error, set_color("Class not found: #{controller_name} (this is a bug. please report)", :red)
    end

    controller = controller_class.new(application: Cnfs.project, options: options, response: response)
    controller.execute

    if options.attach
      controller.run(:attach)
    elsif options.shell
      controller.run(:shell)
    elsif options.console
      controller.run(:console)
    end

    response.run!(:all)
    raise Cnfs::Error, set_color(response.messages, :red) if response.errors.size.positive?
  end
end
