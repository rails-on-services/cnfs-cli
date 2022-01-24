# frozen_string_literal: true

module Hendrix
  class ApplicationCommand < Thor
    # include Hendrix::Concerns::Extendable if defined? APP_ROOT
    attr_accessor :calling_method

    class << self
      def has_class_options(*names) = define_options(names: names, type: :class_)
        
      def has_options(*names) = define_options(names: names)

      def define_options(names:, type: '')
        names.flatten.each do |name|
          raise "Tried to access undefined shared option '#{name}'" unless (opts = shared_options[name])

          send("#{type}option", name, opts)
        end
      end

      def shared_options
        {
          dry_run: { desc: 'Do not execute commands', aliases: '-d', type: :boolean },
          force: { desc: 'Do not prompt for confirmation', aliases: '-f', type: :boolean },
          quiet: { desc: 'Do not output execute commands', aliases: '-q', type: :boolean }
        }
      end

      def exit_on_failure?() = true
    end

    # TODO: Refactor or Remove
    # rubocop:disable Metrics/BlockLength
    class << self
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
    # rubocop:enable Metrics/BlockLength

    private

    # Invokes the appropriate method on the appropriate controller. Default is ExecController#base_execute
    def execute(**kwargs)
      namespace = kwargs.delete(:namespace) || self.class.name.deconstantize
      namespace = nil if namespace.blank?
      controller = kwargs.delete(:controller) || :exec
      method = kwargs.delete(:method)&.to_sym

      # The name of the method that invoked 'execute', e.g. 'console'
      @calling_method = caller_locations(1).first.label.to_sym

      # Arguments and Options that will be passed to the controller
      @args = Thor::CoreExt::HashWithIndifferentAccess.new(kwargs)
      @options = Thor::CoreExt::HashWithIndifferentAccess.new(options)

      controller_klass = controller_class(namespace: namespace, controller: controller)
      # binding.pry
      controller_obj = controller_klass.new(**controller_args)

      # If a method was specified then invoke that method
      # If not, then check if the controller implements a method of the same name as the calling_method
      # Otherwise invoke the default #execute method
      method ||= controller_obj.respond_to?(calling_method) ? calling_method : :execute
      controller_obj.base_execute(method)
    end

    # Return the class to execute using the following priorities:
    # 1. If a controller exists in the same or specified namespace with the name of the calling method then return it
    # 2. Otherwise return the specified or default namespace and controller
    def controller_class(namespace:, controller:) # , method:)
      class_names = [[namespace, calling_method], [namespace, controller]].map { |e| "#{e.compact.join('/')}_controller" }
      # binding.pry
      class_names.each do |class_name|
        next unless (klass = class_name.classify.safe_constantize)

        return klass
      end
      binding.pry
      # Hendrix.logger.debug('controller classes not found:', class_names.join(' '))
      raise Hendrix::Error, set_color("Class not found: #{class_names.join(' ')} (this is a bug. please let us know)", :red)
    end

    # Override to provide custom arguments and/or options to the exec controller
    def controller_args() = { options: options, args: args, command: calling_method }

    # Will raise an error unless force option is provided or user confirms the action
    def validate_destroy(msg = "\n#{'WARNING!!!  ' * 5}\nAction cannot be reversed\nAre you sure?")
      return true if options.force || yes?(msg)

      raise Hendrix::Error, 'Operation cancelled'
    end

    # Used by Hendrix::New and Hendrix::Plugin
		def check_dir(name)
			if Dir.exist?(name) && !validate_destroy('Directory already exists. Destroy and recreate?')
				raise Hendrix::Error, set_color('Directory exists. exiting.', :red)
			end
			true
		end
  end
end
