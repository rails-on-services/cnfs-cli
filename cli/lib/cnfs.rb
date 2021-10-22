# frozen_string_literal: true

require 'pathname'
require 'little-plugger'
require_relative 'cnfs_plugger'

module Cnfs
  extend LittlePlugger
  extend CnfsPlugger

  module Plugins; end # Required by LittlePlugger

  class Error < StandardError; end

  class << self
    attr_writer :project_file, :project_root, :context, :translations

    def project_file
      @project_file ||= 'project.yml'
    end

    def xdg_name
      @xdg_name ||= 'cnfs-cli'
    end

    def project_root
      @project_root ||= Pathname.new(Dir.pwd).ascend { |path| break path if path.join(project_file).file? }
    end

    def context
      # require 'pry'
      # binding.pry if @context.nil?
      @context ||= Cnfs::Context.new(
        cwd: project_root,
        config_parse_settings: { env_separator: '_', env_prefix: 'CNFS' },
        config_paths: [CnfsCli.gem_root.join(project_file), user_root.join('cnfs.yml'), load_p_root],
        translations: translations
      )
    end

    # TODO: This is going to be a problem when run outside of a project since the file will not be available
    def translations
      @translations ||= (
        yml = YAML.load_file(load_p_root)['config']['x_components'] || {}
        translations = yml.each_with_object({}) do |kv, hash|
          next unless (env = kv['env'])

          hash[env] = kv['name']
        end
      )
    end

    def load_p_root
        project_root ? project_root.join(project_file) : project_file
    end

    # The model class list for which tables will be created in the database
    def schema_model_names
      %w[blueprint builder context component dependency environment image node node_asset
        project provider repository resource runtime service user]
    end

    def asset_names
      %w[builders environments providers resources repositories runtimes services users]
    end
  end
end
