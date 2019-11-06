# frozen_string_literal: true

require 'forwardable'

module Cnfs
  class Errors
    attr_reader :messages, :details

    def initialize
      @messages = {}
      @details = {}
    end

    def add(attribute, message = :invalid, options = {})
      @messages[attribute] = message
      @details[attribute] = options
    end

    def size; @messages.size end
  end

  class Command
    extend Forwardable

    def_delegators :command, :run

    class << self
      attr_accessor :registrations, :callbacks

      def registrations; @registration ||= {} end

      def callbacks; @callbacks ||= {} end

      def register(klass, name)
        registrations[name] = klass
      end

      # define callback methods, e.g. :before_validate, :after_execute
      %i[before on after].each do |lifecycle|
        %i[validate execute finalize].each do |event|
          lifecycle_event = [lifecycle, event].join('_').to_sym
          define_method(lifecycle_event) do |callback_method|
            callbacks[lifecycle_event] ||= []
            if callbacks[lifecycle_event].include?(callback_method)
              STDOUT.puts "WARN: '#{callback_method}' #{lifecycle_event} callback already defined"
              return
            end
            callbacks[lifecycle_event].append(callback_method)
          end
        end
      end

      def run_callbacks(lifecycle_event, instance)
        return unless (methods = callbacks[lifecycle_event])

        methods.each do |callback_method|
          instance.output.puts "-> [#{lifecycle_event}] Running '#{callback_method}'" if instance.options.debug > 1
          instance.send(callback_method)
        end
      end
    end

    attr_accessor :input, :output, :errors

    def errors; @errors ||= Cnfs::Errors.new end

    # Execute this command
    #
    # @api public
    def execute(args = {}) # input: $stdin, output: $stdout)
      type = options[:orchestrator]
      self.class.include(self.class.registrations[type]) if type and self.class.registrations[type]
      with_callbacks(args) {}
      self
    end

    def with_callbacks(args)
      @input = $stdin
      @output = $stdout
      self.class.run_callbacks(:before_validate, self)
      self.class.run_callbacks(:on_validate, self)
      self.class.run_callbacks(:aftere_validate, self)
      self.class.run_callbacks(:before_execute, self)
      self.class.run_callbacks(:on_execute, self)
      yield
      self.class.run_callbacks(:after_execute, self)
      self.class.run_callbacks(:before_finalize, self)
      self.class.run_callbacks(:on_finalize, self)
      self.class.run_callbacks(:aftere_finalize, self)
    end

    # TODO: Move these to a concern or the Cnfs::Command class
    def generator_class; generator_name.constantize end

    def generator_name; self.class.name.gsub('Cnfs::Commands', 'Cnfs::Core::Generators') end

    # The external commands runner
    #
    # @see http://www.rubydoc.info/gems/tty-command
    #
    # @api public
    def command(**options)
      require 'tty-command'
      TTY::Command.new(options)
    end

    def command_options; @command_options ||= cmdx_options end

    def cmdx_options
      hash = default_options
      # hash.merge!(printer: :null) unless options.verbose
      hash
    end

    def default_options
      {
        uuid: false,
        only_output_on_error: true
      }
    end

    def cmd_options
      hash = {}
      hash.merge!(only_output_on_error: true) unless options.verbose
      hash
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
    def platform
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
  end
end
