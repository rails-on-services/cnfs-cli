# frozen_string_literal: true
require 'tty-command'

class Response
  include ActiveModel::Model
  attr_accessor :command_name, :options, :output, :input
  attr_accessor :command, :errors, :commands, :results

  def initialize(attributes = {})
    super
    @command = TTY::Command.new(command_options)
    @errors = Cnfs::Errors.new
    @commands = []
    @results = []
  end

  def messages
    errors.full_messages
  end

  def add(exec:, pty: false, env: {}, dir: nil)
    commands << OpenStruct.new(caller: command_name, exec: exec, env: env, pty: pty, dir: dir)
    self
  end

  # Execute enqueued commands - default is to pop the last added command
  # :all will run all commands from the first command added
  # :first will run just the first command
  def run!(type = nil)
    return if errors.size.positive? and options.fail_fast

    while (cmd = commands_to_run(type).shift)
      output.puts(cmd.exec) unless suppress_output
      cmd.pty ? execute_pty(cmd) : execute(cmd)
      break if errors.size.positive? and options.fail_fast
    end
  end

  def commands_to_run(type)
    return [commands.pop] if type.nil?
    return [commands.shift] if type.eql?(:first)
    return commands if type.eql?(:all)
    []
  end

  def execute_pty(cmd)
    result = system(cmd.env, cmd.exec) unless options.noop
    # TODO: improve error handling and reporting
    errors.add(cmd.caller, cmd.exec) unless result
    @results << result
  end

  def execute(cmd)
    begin
      # with_spinner('Building...') do end
      result = command.run(cmd.exec, cmd_options(cmd))
      if result.failure?
        errors.add(cmd.caller, result.err.chomp)
      end
      @results << result.out
    rescue StandardError => e # TTY::Command::ExitError => e
      errors.add(cmd.caller, e.message)
    end
  end

  # Specific running command
  def cmd_options(cmd)
    cmd_options = { pty: cmd.pty }
    cmd_options.merge!(env: cmd.env) unless cmd.env.empty?
    cmd_options.merge!(chdir: cmd.dir) if cmd.dir
    cmd_options
  end

  def command_options
    cmd_options = { uuid: false }
    cmd_options.merge!(dry_run: true) if options.noop
    # cmd_options.merge!(only_output_on_error: !options.debug)
    cmd_options.merge!(printer: :null) if suppress_output
    cmd_options
  end

  def suppress_output
    return false if options.key?(:quiet) and not options.quiet
    return false if (options.verbose || options.debug || options.noop )
    true
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
