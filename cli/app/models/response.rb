# frozen_string_literal: true

class Response
  attr_accessor :name, :controller, :options, :commands

  def initialize(name, controller)
    @name = name
    @controller = controller
    @options = controller.options
    @commands = []
  end

  def add(exec:, env: {}, pty: false)
    commands << OpenStruct.new(exec: exec, env: env, pty: pty)
    self
  end

  # Execute enqueued commands
  def run!
    loop do
      break unless (command = commands.shift)

      if command.pty
        controller.output.puts command.exec if options.verbose or options.debug
        system(command.exec) unless options.noop
      else
        controller.output.puts command.exec if (options.verbose or options.debug) and not options.noop
        # with_spinner('Building...') do end
        result = controller.command(controller.command_options).run!(command.env, command.exec)
        # TODO: Break if a cli switch to fail fast is in effect
        controller.errors.add(name, result.err.chomp) if result.failure?
      end
    end
  end
end
