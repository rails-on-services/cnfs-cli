# frozen_string_literal: true

module CommandHelper
  extend ActiveSupport::Concern

  class_methods do
    def add_cnfs_option(name, options = {})
      @shared_options = {} if @shared_options.nil?
      @shared_options[name] = options
    end

    def cnfs_class_options(*option_names)
      option_names.each do |option_name|
        opt = @shared_options[option_name]
        raise "Tried to access shared option '#{option_name}' but it was not previously defined" if opt.nil?

        class_option option_name, opt
      end
    end

    def cnfs_options(*option_names)
      option_names.each do |option_name|
        opt = @shared_options[option_name]
        raise "Tried to access shared option '#{option_name}' but it was not previously defined" if opt.nil?

        option option_name, opt
      end
    end
  end

  included do |_base|
    add_cnfs_option :environment,       desc: 'Target environment',
                                        aliases: '-e', type: :string, default: Cnfs.config.environment
    add_cnfs_option :namespace,         desc: 'Target namespace',
                                        aliases: '-n', type: :string, default: Cnfs.config.namespace
    add_cnfs_option :repository,        desc: 'The repository in which to run the command',
      aliases: '-r', type: :string, default: Cnfs.config.repository
    add_cnfs_option :source_repository, desc: 'The source repository to link to',
                                        aliases: '-s', type: :string, default: Cnfs.config.source_repository

    add_cnfs_option :tags,              desc: 'Filter by tags',
                                        aliases: '-t', type: :array
    add_cnfs_option :force,             desc: 'Do not prompt for confirmation',
                                        aliases: '-f', type: :boolean
    add_cnfs_option :fail_fast,         desc: 'Skip any remaining commands after a command fails',
                                        aliases: '--ff', type: :boolean

    add_cnfs_option :debug,             desc: 'Display deugging information with degree of verbosity',
                                        aliases: '-d', type: :numeric, default: Cnfs.config.debug
    add_cnfs_option :noop,              desc: 'Do not execute commands',
                                        type: :boolean, default: Cnfs.config.noop
    add_cnfs_option :quiet,             desc: 'Suppress status output',
                                        aliases: '-q', type: :boolean, default: Cnfs.config.quiet
    add_cnfs_option :verbose,           desc: 'Display extra information from command',
                                        aliases: '-v', type: :boolean, default: Cnfs.config.verbose

    Cnfs.extensions.select { |e| e.extension_point.eql?(name) }.each do |extension|
      if extension.klass < Thor
        register(extension.klass, extension.title, extension.help, extension.description)
      else
        include extension.klass
      end
    end

    private

    def initialize_project
      puts "INITIALIZE"
      Cnfs.require_deps
      Cnfs.with_timer('loading project configuration') do
        # TODO: Maybe merge should go elsewhere since the options could be useful even if project is not loaded
        # Merge options also under options key for Project to pick up
        @options.merge!("tags" => Hash[*options.tags.flatten]) if options.tags
        # binding.pry
        Cnfs.config.merge!(options).merge!(options: options)
        Cnfs::Schema.initialize!
        # Cnfs.app.manifest.purge! if Cnfs.app.manifest.outdated?
        # Cnfs.app.manifest.generate
      end
    end

    # def generate_runtime_configs!
    #   manifest.purge! if options.clean
    # end

    def execute(command_args = {}, command_name = nil, location = 2)
      @args = Thor::CoreExt::HashWithIndifferentAccess.new(command_args)
      yield if block_given?
      Cnfs.logger.info("execute: #{command_name}")
      command_name ||= command_method(location)
      exec_instance = command_class(command_name)
      exec_instance.new(options: options, args: args).execute
    end

    # Can be called directory by the command, e.g. 'console' with no params and will return 'console'
    def command_method(location = 1)
      method = caller_locations(1, location)[location -1].label
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

    def ensure_valid_project
      raise Cnfs::Error, set_color(Cnfs.project.errors.full_messages.join("\n"), :red) unless project.valid?
    end

    def services_file_path
      path = [options.environment, options.namespace].compact.join('/')
      # TODO: just reference project?
      Cnfs.project_root.join(Cnfs.paths.config, 'environments', path, 'services.yml')
    end

    # Usage: before: (or class_before:) :validate_destroy
    # Will raise an error unless force option is provided or user confirms the action
    def validate_destroy(msg = "\n#{'WARNING!!!  ' * 5}\nAction cannot be reversed\nAre you sure?")
      return true if options.force || yes?(msg)

      raise Cnfs::Error, 'Operation cancelled'
    end

    # References to instances of the command classes
    def cmd
      OpenStruct.new({
        projects: ProjectsController.new(args, options),
        repositories: RepositoriesController.new(args, options),
        environments: EnvironmentsController.new(args, options),
        namespaces: NamespacesController.new(args, options),
        images: ImagesController.new(args, options),
        services: ServicesController.new(args, options)
      })
    end

    def project
      Cnfs.project
    end
  end
end
