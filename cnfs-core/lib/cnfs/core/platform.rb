# frozen_string_literal: true

module Cnfs::Core
  class Platform
    include Concerns::Common
    attr_reader :env, :profile, :feature_set, :config_files

    def initialize(env: nil, profile: nil, feature_set: nil, partition: nil)
      @env = env&.to_s || ENV.fetch('CNFS_ENV', 'development')
      @profile = profile&.to_s || ENV.fetch('CNFS_PROFILE', nil)
      @feature_set = feature_set&.to_s || ENV.fetch('CNFS_FS', nil)
      @config_files ||= get_config_files
      load_settings
      load_partitions
      config.env = @env
      config.profile = @profile
      config.feature_set = @feature_set
    end

    def load_settings
      config = Cnfs.settings[settings_key] = Config.load_and_set_settings(config_files['platform'] || '')
      config['providers'] = Config.load_and_set_settings(config_files['providers'] || '')
      # @providers = Cnfs::Providers.new(config['providers']).providers
      children.each do |partition_name|
        partition = config[partition_name] ||= Config::Options.new
        partition.merge!(Config.load_and_set_settings(config_files[partition_name] || '').to_hash)
        partition_klass = "#{self.class.name}::#{partition_name.camelize}"
        partition_klass.constantize.children.each do |component_name|
          component = partition[component_name] ||= Config::Options.new
          component.merge!(Config.load_and_set_settings(config_files["#{partition_name}.#{component_name}"] || '').to_hash)
          component_klass = "#{partition_klass}::#{component_name.camelize}"
          component_klass.constantize.children.each do |resource_name|
            resource = component[resource_name] ||= Config::Options.new
            resource.merge!(Config.load_and_set_settings(config_files["#{partition_name}.#{component_name}.#{resource_name}"] || '').to_hash)
          end
        end
      end
      self
    end

    def settings_key; @settings_key ||= (0...8).map { (65 + rand(26)).chr }.join end

    def load_partitions
		  @partitions = []
			children.each do |child|
				self.class.send(:attr_accessor, child)
        klass_name = "#{self.class.name}::#{child.camelize}"
        init_obj = klass_name.constantize.new(self)
				instance_variable_set("@#{child}", init_obj)
				@partitions << instance_variable_get("@#{child}")
			end
    end

    def get_config_files
      Cnfs::Core.config_dirs.each_with_object({}) do |base_cwd, hash|
        read_dir(hash, base_cwd)
			  children.each { |child| read_dir(hash, base_cwd.join(child), '**', child) }
        read_dir(hash, base_cwd.join("environments/#{env}"), '**')
        read_dir(hash, base_cwd.join("environments/#{env}-#{profile}"), '**') if profile
      end
    end

    def read_dir(hash, dir, scope = '', parent_key = nil)
      Dir[dir.join(scope).join('*.yml')].each do |entry|
        key = entry.gsub("#{dir}/", '').gsub('.yml', '').gsub('/', '.')
        key = "#{parent_key}.#{key}" if parent_key
        hash[key] ||= []
        hash[key].append(entry)
      end
    end

    def partition_class(partition)
      "#{self.class.name}::#{partition.camelize}".constantize
    end

    def parent; self end
    def platform; self end

    def settings; Cnfs.settings[settings_key] end
    def config; settings.config.merge!(providers: settings.providers.to_hash) end
    def environment; settings.environment || Config::Options.new end

    def path_for(type = :deployments, partition: nil, component: nil, resource: nil)
      Pathname.new([config.base_path, type, [env, profile].compact.join('-'), partition, component, resource].compact.join('/'))
    end
  end
end
