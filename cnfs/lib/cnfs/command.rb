# frozen_string_literal: true

require 'forwardable'

module Cnfs
  class Command
    extend Forwardable

    def_delegators :command, :run

    class << self
      attr_accessor :callbacks

      def callbacks; @callbacks ||= {} end

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

    attr_accessor :params, :options, :config
    attr_accessor :input, :output, :errors
    attr_accessor :result, :display

    def initialize(params = {}, options = Thor::CoreExt::HashWithIndifferentAccess.new, config = {})
      @params = params
      @options = options
      @config = OpenStruct.new(config)
      @input = $stdin
      @output = $stdout
      @errors = Cnfs::Errors.new
      configure
    end

    def configure
      # type = deployment[:orchestrator]
      # Include a module named Cnfs::Compose::Commands::Application::Backend::Generate
      # mod = self.class.name.gsub('Cnfs', "cnfs/#{type}".classify)
      # self.class.include(mod.constantize) if Object.const_defined?(mod)
      # Include a module named Cnfs::Compose::Common
      # mod = "cnfs/#{type}/common".classify
      # self.class.include(mod.constantize) if Object.const_defined?(mod)
      self.class.constants.each do |mod|
        self.class.include("#{self.class.name}::#{mod}".constantize)
      end
      # binding.pry
    end

    # Execute this command
    #
    # @api public
    def execute(command = nil)
      # Don't pass a command from the router; This is for command chaining
      if command
        cmd = self.class.name.gsub(config.command.to_s, command.to_s.camelize).safe_constantize
        return cmd.new(params, options, config.to_h.merge(command: command.to_s.camelize)).execute
      end
      with_callbacks {}
      self
    end

    def with_callbacks
      self.class.run_callbacks(:before_validate, self)
      self.class.run_callbacks(:on_validate, self)
      self.class.run_callbacks(:aftere_validate, self)
      self.class.run_callbacks(:before_execute, self)
      self.class.run_callbacks(:on_execute, self)
      yield
      self.class.run_callbacks(:after_execute, self)
      self.class.run_callbacks(:before_finalize, self)
      self.class.run_callbacks(:on_finalize, self)
      self.class.run_callbacks(:after_finalize, self)
    end

    def generate_manifests
      execute(:generate) if stale_config
    end

    def stale_config
      manifest_files.empty? || (last_config_file_updated > first_manifest_file_created)
      # Check template files
      # Dir["#{Ros.gem_root.join('lib/ros/be')}/**/{templates,files}/**/*"].each do |f|
      #   return true if mtime < File.mtime(f)
      # end
      # # Check custom templates
      # Dir["#{Ros.root.join('lib/generators')}/be/**/{templates,files}/**/*"].each do |f|
      #   return true if mtime < File.mtime(f)
      # end
    end

    def last_config_file_updated; config_files.map { |f| File.mtime(f) }.max end
    def config_files; config.platform.config_files.values.flatten end

    def first_manifest_file_created; manifest_files.map { |f| File.mtime(f) }.min end
    def manifest_files; Dir[config.platform.path_for.join('**/*')] end

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

    def generator_namespace(command, generate)
      self.class.name.gsub('::Commands::', "::#{command}::").gsub('::Generate', "::#{generate}")
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
  end
end
