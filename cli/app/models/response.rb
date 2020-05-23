# frozen_string_literal: true

class Response
  include ActiveModel::Model
  attr_accessor :command_name, :options, :output, :command, :errors, :commands, :results

  def initialize(attributes = {})
    super
  # def initialize(command_name, options, output, command, errors)
  #   @command_name = command_name
  #   @options = options
  #   @output = output
  #   @command = command
  #   @errors = errors
    @commands = []
    @results = []
  end

  def add(exec:, env: {}, pty: false, dir: nil)
    commands << OpenStruct.new(exec: exec, env: env, pty: pty, dir: dir)
    self
  end

  def run(cmd)
    command.run(cmd, only_output_on_error: !options.debug)
  end

  # Execute enqueued commands
  def run!
    loop do
      break unless (cmd = commands.shift)

      if cmd.pty
        output.puts(cmd.exec) if options.verbose || options.debug
        result = system(cmd.exec) unless options.noop
        # TODO: improve error handling and reporting
        unless result
          errors.add(command_name, cmd.exec)
          break
        end
        @results << result
      else
        output.puts(cmd.exec) if (options.verbose || options.debug) && !options.noop
        command_options = cmd.env.merge(only_output_on_error: !options.debug)
        command_options.merge!(chdir: cmd.dir) if cmd.dir
        # with_spinner('Building...') do end
        result = command.run!(cmd.exec, command_options)
        if result.failure?
          errors.add(command_name, result.err.chomp)
          break
        end
        @results << result.out
      end
    end
  end

  # run command with output captured to variables
  # returns boolean true if command successful, false otherwise
  # def capture_cmd(cmd, envs = {})
  #   return if setup_cmd(cmd)
  #   @stdout, @stderr, process_status = Open3.capture3(envs, cmd)
  #   @exit_code = process_status.exitstatus
  #   @exit_code.zero?
  # end

  # # run command with output captured unless options.verbose then to terminal
  # # returns boolean true if command successful, false otherwise
  # def system_cmd(cmd, envs = {}, never_capture = false)
  #   return capture_cmd(cmd, envs) unless (options.verbose or never_capture)
  #   return if setup_cmd(cmd)
  #   system(envs, cmd)
  #   @exit_code = $?.exitstatus
  #   @exit_code.zero?
  # end

  # def setup_cmd(cmd)
  #   puts cmd if options.verbose
  #   @stdout = nil
  #   @stderr = nil
  #   @exit_code = 0
  #   options.noop
  # end

  # def exit
  #   STDOUT.puts(errors.messages.map{ |(k, v)| "#{v}\n" }) if errors.size.positive?
  #   Kernel.exit(errors.size)
  # end
end
