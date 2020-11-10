# frozen_string_literal: true

module Component
  class ServiceController < Thor
    OPTS = %i[noop quiet verbose]
    include Cnfs::Options
    attr_accessor :action

    def self.default_repository
      # TODO: This is broken
      return '' unless ARGV[2]&.eql?('rails')
      Cnfs.repository_root.split.last.to_s
    end

    def self.repo_options(repository = default_repository)
      path = Cnfs.paths.src.join(repository, '.cnfs.yml')
      hash = path.exist? ? YAML.load_file(path) : {}
      Thor::CoreExt::HashWithIndifferentAccess.new(hash)
    end

    class_option :environment, desc: 'Target environment',
      aliases: '-e', type: :string
    class_option :namespace, desc: 'Target namespace',
      aliases: '-n', type: :string

    desc 'localstack', 'Add a Localstack service'
    def localstack(name = 'localstack')
      generate(:generic, ['restogy', name, 'localstack'])
    end

    desc 'nginx', 'Add a Nginx service'
    def nginx(name = 'nginx')
      generate(:generic, ['restogy', name, 'nginx'])
    end

    desc 'postgres', 'Add a Postgres service'
    def postgres(name = 'postgres')
      generate(:generic, ['restogy', name, 'postgres'])
    end

    desc 'redis', 'Add a Redis service'
    def redis(name = 'redis')
      generate(:generic, ['restogy', name, 'redis'])
    end

    desc 'rails', 'Add a CNFS service based on the Ruby on Rails Framework'
    # option :database, desc: 'Preconfigure for selected database (options: postgresql)',
    #   aliases: '-D', type: :string, default: 'postgresql'
    # option :test_with, desc: 'Testing framework',
    #   aliases: '-t', type: :string, default: 'rspec'
    # TODO: Add options that carry over to the rails plugin new command
    option :repository, desc: 'The repository in which to generate the service',
      aliases: '-r', type: :string, default: default_repository
    option :type, desc: 'The service type to generate, application or plugin',
      aliases: '-t', type: :string, default: repo_options.service_type || 'application'
    option :gem, desc: 'Base this service on a CNFS compatible service gem from rubygems, e.g. cnfs-iam',
      aliases: '-g', type: :string
    option :gem_source, desc: 'Source path to a gem in the project filesystem, e.g. ros/iam (used for development of source gem)',
      aliases: '-s', type: :string
    def rails(name)
      # TODO: options.gem and options.gem_sourcce are only valid if type is application
      generate(:rails, ['restogy', name])
    end

    desc 'iam', 'Add the IAM service'
    def iam(name = 'iam')
      generate(:rails, ['restogy', name])
    end

    desc 'wait', 'Add a Wait service'
    def wait(name = 'wait')
      generate(:generic, ['restogy', name, 'wait'])
    end

    private

    def action
      @action ||= :invoke
    end

    def generate(generator_type, arguments)
      unless (generator_class = "#{generator_type}/service_generator".classify.safe_constantize)
        raise Cnfs::Error, "#{generator_type} service generator class not found"
      end

      generator = generator_class.new(arguments, options.merge(services_file: services_file_path))
      generator.destination_root = repository_root
      generator.behavior = action
      generator.invoke_all
    end

    def services_file_path
      path = [options.environment, options.namespace].compact.join('/')
      Cnfs.project_root.join(Cnfs.paths.config, 'environments', path, 'services.yml')
    end

    def repository_root
      @repository_root ||= options.repository ? Cnfs.paths.src.join(options.repository) : Cnfs.repository_root
    end
  end
end

=begin
    # def hash
    #   hash = repo ? options_string_to_hash(repo.options) : {}
    #   hash.merge!(options_string_to_hash(options.options || ''))
    #   hash.merge!(type: options.type)
    #   hash.merge!(repository_root: repository_root)
    #   hash.merge!(services_file: Cnfs.project_root.join(Cnfs.paths.config, 'environments', options.environment || '', options.namespace || '', 'services.yml'))
    # end

    # def repo
    #   @repo ||= set_repo
    # end

    # def set_repo
    #   Cnfs.require_deps
    #   Cnfs.require_project!(arguments: arguments, options: options, response: nil)
    #   repository_name = repository_root.split.last.to_s

    #   unless (repo = Repository.find_by(name: repository_name))
    #     raise Cnfs::Error, "Repository #{repository_name} not found"
    #   end
    #   repo
    # end

    # def options_string_to_hash(string)
    #   string.split(',').each_with_object({}) { |s, h| k, v = s.split('='); h[k] = v }
    # end
=end
