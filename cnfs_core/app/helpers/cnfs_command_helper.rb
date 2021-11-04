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
  end

  private

  def execute(**kwargs, &block)
    location = kwargs.delete(:location) || 2
    controller_name = kwargs.delete(:controller) || controller_name_from_caller(location: location)
    method_name = kwargs.delete(:method) || :execute
    @args = Thor::CoreExt::HashWithIndifferentAccess.new(kwargs)
    # binding.pry if block_given?
    yield if block_given?

    Cnfs.logger.info("controller name: #{controller_name}")
    controller = controller_instance(controller_name: controller_name)
    controller.new(**controller_args).send(method_name)
  end

  def controller_args
    { options: options, args: args }
  end

  # Could be called directly by the command, e.g. 'console' with no params and will return 'console'
  def controller_name_from_caller(location: 1)
    name = caller_locations(1, location)[location - 1].label
    Cnfs.logger.info("controller name: #{name}")
    name
  end

  def controller_instance(controller_name:)
    class_name = "#{self.class.name.delete_suffix('Controller')}/#{controller_name}_controller".classify
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

  # Run a command on another controller
  # TODO: need to provide the context to the chained command
  def controller_for(command)
    "#{command}_controller".classify.safe_constantize.new # (args, options)
  end
end
