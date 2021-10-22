# frozen_string_literal: true

module CnfsCommandHelper
  extend ActiveSupport::Concern

  class_methods do
    # Add an option and it's values to be referenced by cnfs_class_options or cnfs_options
    def add_cnfs_option(name, options = {})
      @shared_options ||= {}
      @shared_options[name] = options
    end

    def cnfs_class_options(*option_names)
      option_names.flatten.each do |option_name|
        opt = @shared_options[option_name]
        raise "Tried to access shared option '#{option_name}' but it was not previously defined" if opt.nil?

        class_option option_name, opt
      end
    end

    def cnfs_options(*option_names)
      option_names.flatten.each do |option_name|
        opt = @shared_options[option_name]
        raise "Tried to access shared option '#{option_name}' but it was not previously defined" if opt.nil?

        option option_name, opt
      end
    end

    # Add an option and it's values to a specific command in a controller
    # Used by plugin modules to add options to an existing command
    def add_cnfs_method_option(method_name, options_name, **options)
      @cnfs_method_options ||= {}
      @cnfs_method_options[method_name] ||= {}
      @cnfs_method_options[method_name][options_name] = options
    end

    def cnfs_method_options(method_name)
      return unless (command = @cnfs_method_options.try(:[], method_name))

      command.each { |name, values| option name, values }
    end

    def add_cnfs_action(lifecycle_command, method_name)
      lifecycle, *command = lifecycle_command.to_s.split('_')
      command = command.join('_').to_sym
      @cnfs_actions ||= {}
      @cnfs_actions[command] ||= []
      @cnfs_actions[command].append({ lifecycle: lifecycle, method_name: method_name })
    end

    def cnfs_actions(method_name)
      return unless (actions = @cnfs_actions.try(:[], method_name))

      actions.each { |action| send(action[:lifecycle], action[:method_name]) }
    end
  end

  # rubocop:disable Metrics/BlockLength
  included do |_base|
    add_cnfs_option :dry_run,           desc: 'Do not execute commands',
                                        aliases: '-d', type: :boolean, default: Cnfs.config.dry_run
    add_cnfs_option :force,             desc: 'Do not prompt for confirmation',
                                        aliases: '-f', type: :boolean
    add_cnfs_option :logging,           desc: 'Display logging information with degree of verbosity',
                                        aliases: '-l', type: :string, default: Cnfs.config.logging
    add_cnfs_option :quiet,             desc: 'Do not output execute commands',
                                        aliases: '-q', type: :boolean, default: Cnfs.config.quiet

    # Load plugin modules to add options, actions and sub-commands to existing command structure
    Cnfs.plugin_modules_for(mod: CnfsCli, klass: self).each { |mod| include mod }

    private

    # rubocop:disable Metrics/ParameterLists
    def execute(command_args = {}, command_name = nil, location = 2, command_method = :execute)
      @args = Thor::CoreExt::HashWithIndifferentAccess.new(command_args)
      yield if block_given?
      Cnfs.logger.info("execute: #{command_name}")
      command_name ||= command_method(location)
      exec_instance = command_class(command_name)
      exec_instance.new(options: options, args: args).send(command_method)
    end
    # rubocop:enable Metrics/ParameterLists

    # Can be called directory by the command, e.g. 'console' with no params and will return 'console'
    def command_method(location = 1)
      method = caller_locations(1, location)[location - 1].label
      Cnfs.logger.info("command_method: #{method}")
      method
    end

    def command_class(command_name)
      class_name = "#{self.class.name.delete_suffix('Controller')}/#{command_name}_controller".classify
      Cnfs.logger.info("command_class: #{class_name}")
      unless (klass = class_name.safe_constantize)
        raise Cnfs::Error, set_color("Class not found: #{class_name} (this is a bug. please report)", :red)
      end

      klass
    end

    # Usage: before: (or class_before:) :validate_destroy
    # Will raise an error unless force option is provided or user confirms the action
    def validate_destroy(msg = "\n#{'WARNING!!!  ' * 5}\nAction cannot be reversed\nAre you sure?")
      return true if options.force || yes?(msg)

      raise Cnfs::Error, 'Operation cancelled'
    end

    # NOTE: Not currently in use; intended as a class_around option
    def timer(&block)
      Cnfs.with_timer('command processing', &block)
    end

    # Run a command on another command_set controller
    def cmd(command_set)
      "#{command_set}_controller".classify.safe_constantize.new(args, options)
    end
  end
  # rubocop:enable Metrics/BlockLength
end
