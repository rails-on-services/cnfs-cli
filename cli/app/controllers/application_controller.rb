# frozen_string_literal: true

require 'forwardable'

class ApplicationController
  extend Forwardable

  def_delegators :command, :run
  attr_accessor :application, :options, :response
  # attr_accessor :input, :output, :response # , :display
  attr_accessor :name

  def initialize(application:, options:, response:)
    @application = application
    @options = options
    @response = response
    @name = self.class.name.demodulize.delete_suffix('Controller').downcase.to_sym
    run('namespaces/generate') if application.manifest.was_purged? && !name.eql?(:generate)
  end

  # NOTE: Don't pass a command from the router; This is for command chaining
  # TODO: make this method private
  def run(command)
    command_module = command.to_s.index('/') ? '' : "#{self.class.name.module_parent}/"
    controller_name = "#{command_module}#{command}_controller".camelize
    unless (controller_class = controller_name.safe_constantize)
      raise Cnfs::Error, "Class not found: #{controller_name} (this is a bug. please report)"
    end

    controller = controller_class.new(application: application, options: options, response: response)
    response.command_name = controller.name
    controller.execute
    response.command_name = name
  end

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
end
