# frozen_string_literal: true

module Services
  class ExecController
    include Concerns::ExecController

    before_execute :process_before_execute_options

    after_execute :process_after_execute_options

    def process_before_execute_options
      execute_image(:build, *context.services.pluck(:name)) if context.options.build
    end

    # Run a command on the last service specified
    def process_after_execute_options
      return unless (service_name = context.args.services&.last)

      # return unless (_service = context.services.find_by(name: service_name))
      resource = nil
      service = nil
      context.services.where(name: service_name).group_by(&:resource).each do |_resource, services|
        resource = _resource
        service = services.last
      end

      %i[attach sh console].select { |opt| context.options.send(opt) }.each do |after_exec|
        next unless service.respond_to?(after_exec) && (cmd = service.send(after_exec))

        # _service.resource.runtime.execute(cmd.to_sym, resource: resource, services: _service)
        resource.runtime.execute(after_exec, services: [service])
        break
      end
    end

    def execute(cmd = command)
      context.services.group_by(&:resource).each do |resource, services|
        resource.runtime.execute(cmd.to_sym, resource: resource, services: services)
      end
    end

    def restart
      execute(:stop)
      execute(:start)
    end

    def x_restart
      state = index.zero? ? :stopped : :started
      services.each do |service|
        # TODO: update_state moves to the service itself as a callback
        # after_start run the database migrations or whatever is defined in the
        # services.yml
        # In fact, in services.rb there is:
        # 1. array of commands that are configured from yaml
        # 2. that same array is used to define the callbacks
        service.update_state(state).each do |cmd_array|
          result = command.run!(*cmd_array)
          Cnfs.logger.error(result.err) if result.failure?
        end
      end
    end

    def terminate
      # stop(services)
      # clean(services)
      execute(:stop)
      execute(:destroy)
    end

    def attach
      system(*service.attach.take(2))
    end

    def command
      runtime.run(args.command.join(' '), pty: true).run!
    end

    def console
      raise Cnfs::Error, "#{service.name} does not implement the console command" unless service.commands.key?(:console)

      system(*service.console.take(2))
    end

    def before_execute_copy
      src = args.src
      dest = args.dest
      src_service = src.include?(':')
      dest_service = dest.to_s.include?(':')
      raise Cnfs::Error, 'only one of source or destination can be a service' if src_service && dest_service

      raise Cnfs::Error, 'one of source or destination must be a service' unless src_service || dest_service

      # set args.service so super_before_execute can find and set it
      @args = args.merge(service: src.index(':') ? src.split(':')[0] : dest.to_s.split(':')[0])
      super_before_execute
    end

    # TODO: This works, but it's a mess and it creates directories on local project even if file copy fails
    def copy
      if args.dest.instance_of?(Pathname)
        n = args.dest.to_s.delete_prefix(project.write_path(:services).to_s).delete_prefix('/')
        w = project.write_path(:services).join(service.name)
        w.join(Pathname.new(n).split.first).mkpath
        @args = args.merge('dest' => w.join(n).to_s)
      end
      cmd = service.copy(args.src, args.dest)
      Cnfs.logger.info cmd.join("\n")
      result = command.run!(*cmd)
      raise Cnfs::Error, result.err if result.failure?

      # Signal.trap('INT') do
      #   warn("\n#{caller.join("\n")}: interrupted")
      #   # exit 1
      # end
    end

    # cnfs service exec iam ls -l -R
    def exec
      binding.pry
      # command.run(*service.exec(args.command))
    end

    def logs
      trap('SIGINT') { throw StandardError } if options.tail
      command.run(*service.logs)
    rescue StandardError
    end

    def ps
      xargs = args.args.empty? ? {} : args.args
      each_runtime do |_runtime, _runtime_services|
        Cnfs.project.runtime.ps(**xargs)
        queue.execute_all
        # Cnfs.project.runtime = runtime
        # Cnfs.project.runtime.prepare
        # command.run(*Cnfs.project.runtime.ps(**xargs))
      end
      # list = project.runtime.ps(**xargs)
      # puts list
    end

    # TODO: format and status are specific to the runtime so refactor when implementing skaffold
    def ps_format
      return nil unless options.format

      "table {{.ID}}\t{{.Mounts}}" if options.format.eql?('mounts')
    end

    def ps_status
      options.status || :running
    end

    def shell
      raise Cnfs::Error, "#{service.name} does not implement the shell command" unless service.commands[:shell]

      system(*service.shell.take(2))
    end

    # rubocop:disable Metrics/AbcSize
    def show
      modifier = options.modifier || '.yml'
      ary = context.filtered_services.each_with_object([]) do |service, ary|
        show_file = context.path(to: :manifests).join("#{service.name}#{modifier}")
        ary.append(show_file) if show_file.exist?
      end

      if ary.empty?
        Cnfs.logger.warn 'No files found'
        return
      end

      ary.each do |show_file|
        puts("- #{show_file}:\n")
        puts(File.read(show_file))
        puts "\n"
      end
    end
    # rubocop:enable Metrics/AbcSize

    # NOTE: from start_controller
    # before_execute :raise_if_runtimes_empty

    # TODO: Modify to take tags and profiles
    # TODO: The command should return output
    # The controller should resuce/raise any excpetions

    # Invoked against filtered services by default
    # To run against all available services pass it in to the method
    # context.resource_runtime(services: context.services).map(&:start)
    def x_start
      run_callbacks :execute do
        # binding.pry
        context.resource_runtimes.each do |runtime|
          runtime.execute(:start)
          # binding.pry
          # runtime.start do |queue|
          #   binding.pry
          #   queue.run
          #   queue.map(&:to_a).flatten.each do |msg|
          #     Cnfs.logger.warn(msg)
          #   end
          # end
        end
      end
    end

    def stop
      # queue = CommandQueue.new
      each_runtime do |runtime, runtime_services|
        cmd_array = runtime.stop(runtime_services)
        queue.execute_all
        binding.pry
        # TODO: if the cmd_array has meta with the service command to invoke and this is in a command class
        # Then the class could auto invoke the command which triggers any callbacks
        # result = command.run!(*cmd_array)
        # raise Cnfs::Error, result.err if result.failure?

        # runtime_services.each do |service|
        #   # Trigger the service's after_start callbacks which may add commands to the service's command_queue
        #   service.stop
        #   service.command_queue.each do |cmd_array|
        #     Cnfs.logger.debug cmd_array
        #     result = command.run!(*cmd_array)
        #     Cnfs.logger.error(result.err) if result.failure?
        #   end
        # end
      end
    end

    def terminate
      each_runtime do |runtime, runtime_services|
        cmd_array = runtime.terminate(runtime_services).each do |cmd_array|
          # TODO: if the cmd_array has meta with the service command to invoke and this is in a command class
          # Then the class could auto invoke the command which triggers any callbacks
          result = command.run!(*cmd_array)
          raise Cnfs::Error, result.err if result.failure?
        end

        runtime_services.each do |service|
          # Trigger the service's after_start callbacks which may add commands to the service's command_queue
          service.terminate
          service.command_queue.each do |cmd_array|
            Cnfs.logger.debug cmd_array
            result = command.run!(*cmd_array)
            Cnfs.logger.error(result.err) if result.failure?
          end
        end
      end
      # project.runtime.terminate(services).each do |cmd_array|
      #   command.run(*cmd_array)
      # end
    end
  end
end
