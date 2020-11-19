# frozen_string_literal: true

module Cnfs
  module Options
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
      add_cnfs_option :environment, desc: 'Target environment',
                                    aliases: '-e', type: :string, default: Cnfs.config.environment
      add_cnfs_option :namespace,   desc: 'Target namespace',
                                    aliases: '-n', type: :string, default: Cnfs.config.namespace
      add_cnfs_option :repository,  desc: 'The repository in which to run the command',
                                    aliases: '-r', type: :string, default: Cnfs.repository&.name
      add_cnfs_option :source_repository,  desc: 'The source repository to link to',
        aliases: '-s', type: :string, default: Cnfs.config.source_repository

      add_cnfs_option :tag,         desc: 'Filter services by tag',
                                    aliases: '-t', type: :string
      add_cnfs_option :force,       desc: 'Do not prompt for confirmation',
                                    aliases: '-f', type: :boolean
      add_cnfs_option :fail_fast,   desc: 'Skip any remaining commands after a command fails',
                                    aliases: '--ff', type: :boolean

      add_cnfs_option :debug,       desc: 'Display deugging information with degree of verbosity',
                                    aliases: '-d', type: :numeric, default: Cnfs.config.debug
      add_cnfs_option :noop,        desc: 'Do not execute commands',
                                    type: :boolean, default: Cnfs.config.noop
      add_cnfs_option :quiet,       desc: 'Suppress status output',
                                    aliases: '-q', type: :boolean, default: Cnfs.config.quiet
      add_cnfs_option :verbose,     desc: 'Display extra information from command',
                                    aliases: '-v', type: :boolean, default: Cnfs.config.verbose

      Cnfs.extensions.select { |e| e.extension_point.eql?(name) }.each do |extension|
        if extension.klass < Thor
          register(extension.klass, extension.title, extension.help, extension.description)
        else
          include extension.klass
        end
      end

      private

      def set_repository
        unless (Cnfs.repository = Cnfs.repositories[options.repository.to_sym])
          raise Cnfs::Error, "Unknown repository '#{options.repository}'." \
            " Valid repositories:\n#{Cnfs.repositories.keys.join("\n")}"
        end
      end

      def services_file_path
        path = [options.environment, options.namespace].compact.join('/')
        Cnfs.project_root.join(Cnfs.paths.config, 'environments', path, 'services.yml')
      end
    end
  end
end
