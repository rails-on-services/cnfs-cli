# frozen_string_literal: true

class Blueprint < ApplicationRecord
  # include Concerns::HasEnv
  # include Concerns::Taggable
  belongs_to :builder
  belongs_to :environment
  belongs_to :provider
  has_many :resources

  delegate :project, to: :environment
  delegate :paths, :path, to: :project

  # parse_sources :project, :user
  # parse_scopes :environment

  # List of resource classes that are managed by this blueprint
  def resource_classes
    []
  end

  # Used by builder to set the template's context to this blueprint
  def _binding
    binding
  end

  def as_save
    # attributes.slice('config', 'envs', 'tags', 'type').merge(
    attributes.slice('config', 'type').merge(
      {
        builder: builder&.name,
        provider: provider&.name,
      }
    )
  end

  def save_path
    paths.config.join('environments', environment.name, 'blueprints.yml')
  end

  class << self
    def available_types(platform)
      defined_types.select{ |p| p.start_with?(platform.to_s) }.map { |p| p.split('/').second }.sort
    end

    def available_platforms
      defined_types.map { |p| p.split('/').first }.uniq.sort
    end

    def defined_types
      @defined_types ||= defined_files.select { |p| p.split('/').size > 1  }.map { |p| p.delete_suffix('.rb') }
    end

    def defined_files
      # CnfsCli.plugins.values.map(&:to_s).sort.each_with_object([]) do |p, ary|
      CnfsCli.plugins.values.each_with_object([]) do |p, ary|
        path = p.gem_root.join('app/models/blueprint')
        next unless path.exist?

        Dir.chdir(path) { ary.concat(Dir['**/*.rb']) }
      end
    end

    def create_table(schema)
      schema.create_table :blueprints, force: true do |t|
        t.references :builder
        t.references :environment
        t.references :provider
        t.string :config
        # t.string :envs
        t.string :name
        # t.string :tags
        t.string :type
      end
    end
  end
end
