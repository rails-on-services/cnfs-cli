# frozen_string_literal: true

module Cnfs
  class Project
    include ActiveModel::Model
    include ActiveModel::Validations
    # CONFIG_FILE = 'application.yml'

    attr_reader :base_project_name, :project_name, :root, :user_root, :paths, :config
    attr_accessor :arguments, :options
    attr_accessor :environment, :namespace, :service, :services
    attr_accessor :runtime, :manifest
    attr_accessor :response

    def initialize(root:, arguments:, options:, response:)
      @base_project_name = self.class.module_parent.to_s.underscore
      @root = Pathname.new(root)
      @user_root ||= Cnfs.xdg.config_home.join('cnfs').join(base_project_name)
      @arguments = arguments
      @options = options
      @response = response

      # @config = Config.load_files(paths['config'].map { |path| path.join(CONFIG_FILE) })
      @config = Config::Options.new
      # TODO: Is path modification even necessary now?
      # paths['db'].unshift(Cnfs.gem_root.join('db'))
      paths['app/views'].unshift(Cnfs.gem_root.join('app/views'))
      compile_fixtures

      Cnfs::Schema.dir = write_path(:fixtures)
      puts 'Loading configuration...' if options.debug.positive?
      Cnfs::Schema.initialize!
      puts 'Loaded' if options.debug.positive?
    end

    # TODO: This would include any dirs from the project directory
    def initialize!
      Cnfs.invoke_plugins_wtih(:on_project_initialize)
      @environment = Environment.find_by(name: options.environment)
      @namespace = Namespace.find_by(name: options.namespace)
      @service = Service.find_by(name: arguments.service) if arguments.service
      @services = Service.where(name: arguments.services) if arguments.services
      @manifest = Manifest.new(config_files_paths: paths['config'], manifests_path: write_path)
      manifest.purge! if manifest.outdated?
      return unless (@runtime = environment&.runtime)

      runtime.application = self
      runtime.options = options
      runtime.response = response
      runtime.before_execute
    end

    def reload
      compile_fixtures
      Cnfs::Schema.reload
    end

    validates :environment, presence: true
    validates :namespace, presence: { message: 'not found' }
    validates :service, presence: { message: 'not found' }, if: -> { arguments.service }
    validate :all_services, if: -> { arguments.services }
    validates :runtime, presence: true

    def all_services
      names = arguments.services
      errors.add(:services, 'Cannot be zero') if names.size.zero?
      invalid_services = names - services.pluck(:name)
      errors.add(:invalid_services, invalid_services.join(', ')) if invalid_services.size.positive?
    end

    # Used by all runtime templates; Returns a path relative from the write path to the project root
    # Example: relative_path(:deployment) # => #<Pathname:../../../..>
    def relative_path(path_type = :deployment)
      root.relative_path_from(root.join(write_path(path_type)))
    end

    # Returns a path relative from the project root
    # Example: write_path(:deployment) # => #<Pathname:tmp/cache/development/main>
    def write_path(type = :deployment)
      type = type.to_sym
      case type
      when :deployment
        Cnfs.paths.tmp.join('cache', *project_name_attrs)
      when :infra
        Cnfs.paths.data.join('infra', options.environment)
      when :runtime
        Cnfs.paths.tmp.join('runtime', *project_name_attrs)
      when :fixtures
        Cnfs.paths.tmp.join('dump')
      when :repositories
        Cnfs.paths.src
      when :config
        Cnfs.paths.config.join('environments', *project_name_attrs)
      end
    end

    def full_project_name
      project_name_attrs.unshift(base_project_name).join('_')
    end

    def project_name
      project_name_attrs.join('_')
    end

    # Used by runtime generators for templates by runtime to query services
    def labels
      { project: full_project_name }.merge(options.slice('environment', 'namespace'))
    end

    def project_name_attrs
      options.slice('environment', 'namespace').values
    end

    def apps_path
      root.join(Cnfs.config.paths.src)
    end

    def paths
      @paths ||= setup_paths
    end

    def setup_paths
      %w[config app/views].each_with_object({}) do |path, hsh|
        hsh[path] = [root.join(path), user_root.join(path)]
      end
    end

    def generate_runtime_configs!
      manifest.purge! if options.clean
      generator = runtime.generator_class.new([], options)
      generator.application = self
      generator.invoke_all
    end

    def runtime_services(format:, status:)
      runtime.runtime_services(format: format, status: status)
    end

    def build
      runtime.build(services)
    end

    def exec(service, command, pty)
      runtime.exec(service, command, pty)
    end

    def restart
      runtime.restart
    end

    def start
      runtime.start
    end

    def stop
      runtime.stop
    end

    # Used by runtime generator to iterate over services
    def selected_services
      Service.all
    end

    # scope is either :namespace or :environment
    def encrypt(plaintext, scope)
      send(scope).encrypt(plaintext)
    end

    def decrypt(ciphertext)
      namespace.decrypt(ciphertext)
    rescue Lockbox::DecryptionError => e
      environment.decrypt(ciphertext)
    end

    def compile_fixtures
      # 1. If the file environments.yml exists and it has the key from options.environment write that to fixtures file
      # 2. If that fails then if the directory from options.environment exists then write that to fixtures file
      # 3. Otherwise continue
      FileUtils.mkdir_p(write_path(:fixtures))
      if options.environment && Cnfs.paths.config.join('environments', options.environment).exist?
        File.open("#{write_path(:fixtures)}/environments.yml", 'w') { |f| f.write("#{options.environment}:\n  name: #{options.environment}\n  key: #{options.environment}\n  runtime: compose") }
        # if Cnfs.paths.config.join('environments', options.environment, "#{options.namespace}.yml").exist?
        if options.namespace && Cnfs.paths.config.join('environments', options.environment, options.namespace).exist?
          File.open("#{write_path(:fixtures)}/namespaces.yml", 'w') { |f| f.write("#{options.namespace}:\n  name: #{options.namespace}\n  key: #{options.namespace}") }
        end
        # if Cnfs.paths.config.join('environments', options.environment, 'namespaces.yml').exist?
        #   path = Cnfs.paths.config.join('environments', options.environment, 'namespaces.yml')
        #   ns = Config.load_file(path)
        #   config = Config::Options.new({ options.namespace => ns[options.namespace].to_hash })
        #   ns.save(write_path(:fixtures).join('namespaces.yml'), config)
        #   binding.pry
        # end
      end
      fixtures.each do |fixture|
        files = config_file_paths(fixture)
        o_config = files.each_with_object(Config::Options.new) do |file, cfg|
          cfg.merge!(Config.load_files(file).to_hash)
        end
        # TODO: some way to have namespace and key names to be composite of target name + namespace name
        o_config.keys.each { |key| o_config[key].name = key.to_s }
        value = o_config.to_hash.deep_stringify_keys.to_yaml
        File.open("#{write_path(:fixtures)}/#{fixture[:name]}.yml", 'w') { |f| f.write(value) }
        # File.open(write_path(:fixtures).join(fixture[:name], '.yml'), 'w') { |f| f.write(value) }
        # rescue StandardError => e
        #  binding.pry
      end
      puts "-----\n> = loaded\n* = not found\n-----" if options.debug.positive?
    end

    # Return an array of files to load for a specific fixture given its sources and scopes
    def config_file_paths(fixture)
      name = (fixture[:alias] || fixture[:name]).to_s
      fixture[:scopes].each_with_object([]) do |scope, ary|
        fixture[:sources].each_with_object(ary) do |source, ary|
          path = path_from_scope(name, scope, source, fixture[:dir])
          pname = name.singularize
          log_string = "#{pname}#{' ' * (12 - pname.length)}#{source}#{' ' * (12 - source.length)}#{scope}#{' ' * (12 - scope.length)}#{path}"
          if File.exist?(path)
            ary.append(path)
            puts "> #{log_string}" if options.debug.positive?
          else
            puts "* #{log_string}" if options.debug.positive?
          end
        end
      end
    end

    def path_from_scope(name, scope, source, dir)
      ary = [path_from_source(source)]
      ary.append(dir) if dir
      ary.append(options.environment) if %i[environment namespace].include?(scope)
      ary.append(options.namespace) if scope.eql?(:namespace)
      ary.append("#{name}.yml").join('/')
    end

    def path_from_source(source)
      return Cnfs.gem_root.join('config') if source.eql?(:cli)
      return Cnfs.paths.config if source.eql?(:project)
      return user_root.join('config') if source.eql?(:user)
    end

    # Scope is by default project and user; other scopes are :user and :gem
    def fixtures
      [
        # { name: :applications, types: [:app] },
        { name: :assets, scopes: [:global], sources: [:project] },
        { name: :blueprints, scopes: %i[global environment namespace], sources: [:project], dir: :environments },
        # { name: :contexts },
        # { name: :deployments },
        { name: :keys, scopes: %i[environment namespace], sources: [:user], dir: :environments },
        # { name: :namespaces, scopes: [:environment], sources: [:project, :user] },
        { name: :providers, scopes: [:global], sources: [:project] },
        { name: :repositories, scopes: [:global], sources: [:project] },
        # { name: :resources, scopes: [:global, :environment, :namespace], sources: [:project, :user] },
        { name: :runtimes, scopes: [:global], sources: %i[cli project user] },
        { name: :services, scopes: %i[global environment namespace], sources: [:project], dir: :environments },
        # { name: :tags, types: [:app, :infra] },
        # { name: :targets, alias: :environments, scopes: [:global], sources: [:project, :user] },
        { name: :users, scopes: [:global], sources: [:project] }
      ]
    end

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    # TODO: This is a quick and dirty to get the project name w/out loading the entire project
    # Fix this when refactoring to A/R models
    def self.x_name
      descendants.pop.module_parent.to_s.underscore
    end
  end
end
