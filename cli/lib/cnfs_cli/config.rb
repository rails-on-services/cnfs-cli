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

    def name
      @name ||= yaml['name']
    end

    def before_set_config
      config_attributes.append(:project, :load_nodes)
      base = 'CNFS_'
      env_translations.each do |short, long|
        ENV["#{base}#{long}".upcase] = ENV.delete("#{base}#{short}".upcase)
      end
    end

    def config_parse_settings
      @config_parse_settings ||= { use_env: true, env_separator: '_', env_prefix: 'CNFS' }
    end

    def env_translations
      @env_translations ||= project ? set_env_translations : {}
    end

    # Read project.yml config.x_components array of hashes for any hash that has the key 'env'
    # Example return hash: { 'tar' => 'target', 'ns' => 'namespace' }
    def set_env_translations
      return {} unless yml = yaml['components']

      yml.each_with_object({}) do |kv, hash|
        next unless (env = kv['env'])

        hash[env] = kv['name']
      end
    end

    def command_options
      @command_options ||= set_command_options
    end

    def set_command_options
      config.components.each_with_object([]) do |opt, ary|
        opt = opt.to_h.with_indifferent_access
        ary.append({ name: opt[:name].to_sym,
                     desc: opt[:desc] || "Specify #{opt[:name]}",
                     aliases: opt[:aliases],
                     type: :string,
                     default: opt[:default]
        })
      end
    end

    def command_options_list
      @command_options_list ||= config.components.map{ |comp| comp[:name].to_sym }
    end

    def yaml
      @yaml ||= YAML.load_file(file) || {}
    end
  end
end
