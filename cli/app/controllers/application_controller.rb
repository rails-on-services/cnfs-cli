# frozen_string_literal: true

require 'forwardable'

class ApplicationController
  extend Forwardable

  def_delegators :command, :run

  attr_accessor :args, :options, :context, :manifest # :response
  attr_accessor :input, :output, :errors
  attr_accessor :result, :display

  def initialize(args, options, context = nil)
    @input = $stdin
    @output = $stdout

    cmd = OpenStruct.new(group: command_group, module: command_module, name: command_name.to_sym,
                         object: command(command_options(options)))
    @context = context || Request.new(args: args, options: options, output: output, command: cmd)
    output_debug if options.debug
  end

  # Don't pass a command from the router; This is for command chaining
  # TODO: make this method private
  # def call(command = nil)
  def call(command, target = nil)
    current_command = self.class.name.demodulize
    called_command = "#{command}_controller".camelize
    controller_class = self.class.name.gsub(current_command, called_command).safe_constantize
    conn = controller_class.new(context.args, context.options, context)
    # raise Cnfs::Error, conn.error_messages unless conn.valid?
    if target
      conn.execute_on_target
    else
      conn.execute
    end
  end

  def before_execute_on_target
    context.runtime.before_execute_on_target
    @manifest = Manifest.new(config_files_paths: Cnfs.application.paths['db'], manifests_path: context.write_path)
    regenerate_config! if manifest.regenerate?
  end

  # Regenerate config if needed
  def regenerate_config!
    FileUtils.rm_rf(manifest.manifest_files)
    # show_output = context.options.key?('debug') || context.options.verbose
    # Cnfs.silence_output(!show_output) { call(:generate) }
    call(:generate, context.target)
  end

  def post_start_options
    if options.attach
      call(:attach, context.target)
    elsif options.shell
      call(:shell, context.target)
    elsif options.console
      call(:console, context.target)
    end
  end

  def error_messages; context.errors.full_messages.join("\n") end

  def valid?; context.valid? end

  def command_module
    self.class.name.underscore.split('/').first
  end

  def command_name
    self.class.name.demodulize.underscore.delete_suffix('_controller')
  end

  def output_debug
    output.puts \
      "   ENVs: #{ENV.select { |env| env.start_with? 'CNFS_' }}\n" \
      "context: #{context.base.name}\n" \
      "options: #{options}\n" \
      "   args: #{args}"
  end

  # Execute this command
  #
  # @api public
  def execute
    raise NotImplementedError
  end

  # The external commands runner
  #
  # @see http://www.rubydoc.info/gems/tty-command
  #
  # @api public
  def command(**options)
    require 'tty-command'
    TTY::Command.new(options)
  end

  def command_options(options)
    cmd_options = { uuid: false }
    cmd_options.merge!(dry_run: true) if options.noop
    cmd_options.merge!(printer: :null) if options.quiet
    cmd_options
  end

  # The cursor movement
  #
  # @see http://www.rubydoc.info/gems/tty-cursor
  #
  # @api public
  def cursor
    require 'tty-cursor'
    TTY::Cursor
  end

  # Open a file or text in the user's preferred editor
  #
  # @see http://www.rubydoc.info/gems/tty-editor
  #
  # @api public
  def editor
    require 'tty-editor'
    TTY::Editor
  end

  # File manipulation utility methods
  #
  # @see http://www.rubydoc.info/gems/tty-file
  #
  # @api public
  def generator
    require 'tty-file'
    TTY::File
  end

  # Terminal output paging
  #
  # @see http://www.rubydoc.info/gems/tty-pager
  #
  # @api public
  def pager(**options)
    require 'tty-pager'
    TTY::Pager.new(options)
  end

  # Terminal platform and OS properties
  #
  # @see http://www.rubydoc.info/gems/tty-pager
  #
  # @api public
  def host
    require 'tty-platform'
    TTY::Platform.new
  end

  # The interactive prompt
  #
  # @see http://www.rubydoc.info/gems/tty-prompt
  #
  # @api public
  def prompt(**options)
    require 'tty-prompt'
    TTY::Prompt.new(options)
  end

  # Get terminal screen properties
  #
  # @see http://www.rubydoc.info/gems/tty-screen
  #
  # @api public
  def screen
    require 'tty-screen'
    TTY::Screen
  end

  # The unix which utility
  #
  # @see http://www.rubydoc.info/gems/tty-which
  #
  # @api public
  def which(*args)
    require 'tty-which'
    TTY::Which.which(*args)
  end

  # Check if executable exists
  #
  # @see http://www.rubydoc.info/gems/tty-which
  #
  # @api public
  def exec_exist?(*args)
    require 'tty-which'
    TTY::Which.exist?(*args)
  end

  # TODO: Integrate this method into standard flow
  def publish_results
    require 'tty-table'
    table = TTY::Table.new(%w[Commands Errors], errors.messages.to_a)
    output.puts "\n"
    output.puts table.render(:basic, alignments: %i[left left], padding: [0, 4, 0, 0])
  end

  # TODO: Test
  def with_spinner(spin_msg)
    if options.quiet
      require 'tty-spinner'
      spinner = TTY::Spinner.new("[:spinner] #{spin_msg}", format: :pulse_2)
      spinner.auto_spin # Automatic animation with default interval
    end
    result = yield
    if options.quiet
      spinner_msg = result.failure? ? 'Failed!' : 'Done!'
      spinner.stop(spinner_msg)
    end
    errors.add(:build, result.err.chomp) if result.failure?
  end

  # class << self
  #   attr_accessor :callbacks

  #   def callbacks; @callbacks ||= {} end

  #   # define callback methods, e.g. :before_validate, :after_execute
  #   %i[before on after].each do |lifecycle|
  #     %i[validate execute finalize].each do |event|
  #       lifecycle_event = [lifecycle, event].join('_').to_sym
  #       define_method(lifecycle_event) do |callback_method|
  #         callbacks[lifecycle_event] ||= []
  #         if callbacks[lifecycle_event].include?(callback_method)
  #           STDOUT.puts "WARN: '#{callback_method}' #{lifecycle_event} callback already defined"
  #           return
  #         end
  #         callbacks[lifecycle_event].append(callback_method)
  #       end
  #     end
  #   end

  #   def run_callbacks(lifecycle_event, instance)
  #     return unless (methods = callbacks[lifecycle_event])

  #     methods.each do |callback_method|
  #       instance.output.puts "-> [#{lifecycle_event}] Running '#{callback_method}'" if instance.options.debug > 1
  #       instance.send(callback_method)
  #     end
  #   end
  # end

  # def with_callbacks
  #   self.class.run_callbacks(:before_validate, self)
  #   self.class.run_callbacks(:on_validate, self)
  #   self.class.run_callbacks(:aftere_validate, self)
  #   self.class.run_callbacks(:before_execute, self)
  #   self.class.run_callbacks(:on_execute, self)
  #   yield
  #   self.class.run_callbacks(:after_execute, self)
  #   self.class.run_callbacks(:before_finalize, self)
  #   self.class.run_callbacks(:on_finalize, self)
  #   self.class.run_callbacks(:after_finalize, self)
  # end
end
