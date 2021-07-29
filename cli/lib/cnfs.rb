# frozen_string_literal: true

require 'pathname'
require 'little-plugger'
require_relative 'cnfs_plugger'

module Cnfs
  extend LittlePlugger
  extend CnfsPlugger

  # Required by LittlePlugger
  module Plugins; end

  class Error < StandardError; end

  class << self
    attr_accessor :context, :model_names

    def prepare_fixtures(models)
      if config_mode.blank?
        raise Cnfs::Error, "Project can have top level environments OR stacks, but not both.\n" \
                           'Stacks may have environments. Environments can NOT have stacks'
      end

      @model_names = models.map(&:table_name)
      load_config(Cnfs.paths.config)
      fixture_resources.each do |fixture_file, values|
        yaml_file = Cnfs::Configuration.fixtures_dir.join(fixture_file)
        File.open(yaml_file, 'w') { |f| f.write(values.to_yaml) }
        # File.open(yaml_file, 'w') { |f| f.write(values.deep_stringify_keys.to_yaml) }
      end
    end

    def load_config(path)
      path.each_child do |node|
        if (data = node_data(node))
          (fixture_resources[data[:fixture_file]] ||= {}).merge!(data[:content])
        end
        load_config(node) if node.directory?
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def node_data(node)
      # config/users.yml config/stacks/backend/providers.yml
      node_sub = node.sub('config', 'project/project')
      node_name = node_sub.basename.to_s.delete_suffix(node.extname)
      parent_ref = node_sub.parent
      content = nil
      if model_names.include?(node_name.pluralize)
        content = YAML.load_file(node) if node.file?
      else
        # TODO: Parse content using has_many and make it recursive
        # TODO: Maybe also use this to validate names of dirs/files
        # parent_klass.reflect_on_all_associations(:has_many).map(&:name).include?(node_name)
        content = node.file? ? { node_name => YAML.load_file(node) } : { node_name => {} }
        node_name = node_sub.parent.basename.to_s
        parent_ref = node_sub.parent.parent
      end
      return unless content

      { fixture_file: "#{node_name.pluralize}.yml", content: node_content(node, node_name, parent_ref, content) }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def node_content(node, node_name, parent_ref, content)
      return { project: content } if node_name.eql?('project')

      # TODO: owner_name is not correct
      owner_name = parent_ref.basename.to_s
      owner_type = parent_ref.parent.basename.to_s.classify
      # owner_id = ActiveRecord::FixtureSet.identify(owner_name)
      # TODO: AR::Base should turn __source into Pathname automagically
      attr_hash = { 'owner' => "#{owner_name} (#{owner_type})", '__source' => node.to_s }
      content.each { |key, value| value.merge!(attr_hash.merge('name' => key)) }
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def config_mode
      @config_mode ||= begin
        envs = paths.config.join('environments').directory? || paths.config.join('environments.yml').file?
        stacks = paths.config.join('stacks').directory? || paths.config.join('stacks.yml').file?
        ret_val = '' if envs && stacks
        ret_val = 'none' unless envs || stacks
        ret_val ||= envs ? 'environments' : 'stacks'
        ActiveSupport::StringInquirer.new(ret_val)
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    def fixture_resources
      @fixture_resources ||= {}
    end

    def repositories
      @repositories ||= {}
    end
  end
end
