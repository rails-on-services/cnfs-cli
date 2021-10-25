# frozen_string_literal: true

# exec: The string to pass to the shell to run
# env: Hash of ENV vars to pass to the shell to run
# opts: Hash of custom options converted into:
#   1. a Hash of command_options for a TTY::Command instance
#   2. a Hash of run_options for the instance's run method
require 'tty-command'

class Command
  include ActiveModel::AttributeAssignment

  attr_accessor :exec, :env, :opts
  # attr_reader :cmd_opts, :run_opts, :result, :exit_error
  attr_reader :result, :exit_error

  delegate :out, :err, to: :result, allow_nil: true

  def initialize(**attrs)
    assign_attributes(**attrs) if attrs.size.positive?
    @env ||= {}
    @opts ||= {}
    @opts.transform_keys!(&:to_sym)
    @opts = opts_defaults.merge(@opts)
  end

  def run!(exec: nil, env: {}, opts: {})
    run(method: :run!, exec: exec, env: env, opts: opts)
  end

  # run will throw an exception if the command fails
  # run! will do what?
  def run(method: :run, exec: nil, env: {}, opts: {})
    return if @result || @exit_error

    @exec = exec if exec
    @env.merge!(env)
    @opts.merge!(opts).transform_keys!(&:to_sym)
    @result = command.send(method, @env, @exec, run_opts)
  rescue TTY::Command::ExitError => err
    @exit_error = err
  ensure
    return self
  end

  def command
    TTY::Command.new(**cmd_opts)
  end

  def to_a(term = "\n")
    out ? out.split(term) : []
  end

  def run_opts
    @run_opts ||= opts.slice(*run_keys)
  end

  # The options keys that are attributes of the run and run! methods
  def run_keys
    %i[verbose pty only_output_on_error in out err]
  end

  def cmd_opts
    @cmd_opts ||= opts.slice(*cmd_keys)
  end

  # The options keys that are attributes of the command object
  def cmd_keys
    %i[uuid dry_run printer]
  end

  def opts_defaults
    { uuid: false }
  end

  private

  # TODO: It will be a complex map of an external key to a hash of TTY::Command cmd and run options
  def transform_keys
   {a: 1, b: 2}.transform_keys{ |key| key_map[key] || key }
  end

  def key_map
    { silent: :only_output_on_error }
  end

  # options for the TTY command
  def set_command_options(context)
    defaults = { uuid: false }
    defaults.merge!(dry_run: true) if context.options.key?(:dry_run)
    defaults
  end

  def set_run_options(context)
    defaults = {}
    defaults.merge!(verbose: true) if context.options.verbose
    defaults.merge!(pty: true) if 1 == 2
    defaults.merge!(only_output_on_error: true) if context.options.quiet
    defaults
  end
end
