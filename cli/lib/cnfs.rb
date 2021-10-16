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
    attr_accessor :project_file, :project_root, :context

    def project_file
      @project_file ||= 'project.yml'
    end

    def project_root
      @project_root ||= context.class.cwd.ascend { |path| break path if path.join(project_file).file? }
    end

    def context
      @context ||= Cnfs::Context.new(
        config_parse_settings: { env_separator: '_', env_prefix: 'CNFS' },
        config_paths: [plugin_root.gem_root.join(project_file), user_root.join('cnfs.yml'), project_file],
        translations: { env: :environment, ns: :namespace, repo: :repository }
      )
    end

    def schema_model_names
      %w[blueprint builder context dependency environment image namespace node node_config node_asset
        project provider repository resource runtime service stack target user]
    end

      # return true if the directory from which the command was invoked is not inside an existing project
      def path_outside_project?(path)
        Dir.chdir(path) { Cnfs.project_root.nil? }
      end
  end
end
