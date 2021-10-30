# frozen_string_literal: true
require 'active_support/inflector'

module CnfsCli
  class Config < Cnfs::ConfigBase
    attr_accessor :load_nodes

    def project
      file.exist?
    end

    def xdg_name
      "cnfs-cli/#{name}"
    end

    def before_set_config
      config_attributes.append(:project, :load_nodes)
      @config_parse_settings = { use_env: true, env_separator: '_', env_prefix: 'CNFS' }
      base = 'CNFS_'
      env_translations.each do |short, long|
        ENV["#{base}#{long}".upcase] = ENV.delete("#{base}#{short}".upcase)
      end
    end

    def after_set_config(config)
      config.order = config.config.x_components.map(&:name).map(&:singularize) if config.config&.x_components
      config.order ||= ['target']
      config.order = config.order.unshift('project')
      config.orders = config.order.map(&:pluralize)
    end

    def env_translations
      @env_translations ||= project ? set_env_translations : {}
    end

    # Read project.yml config.x_components array of hashes for any hash that has the key 'env'
    # Example return hash: { 'tar' => 'target', 'ns' => 'namespace' }
    def set_env_translations
      return {} unless (yml = YAML.load_file(file).dig('config', 'x_components'))

      yml.each_with_object({}) do |kv, hash|
        next unless (env = kv['env'])

        hash[env] = kv['name']
      end
    end
  end
end
