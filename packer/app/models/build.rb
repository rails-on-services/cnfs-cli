# frozen_string_literal: true

class Build < ApplicationRecord
  include Concerns::BelongsToProject

  belongs_to :source, class_name: 'Build', required: false
  has_many :children, class_name: 'Build', foreign_key: 'source_id'

  has_many :builders
  has_many :provisioners
  has_many :post_processors

  # store :config, accessors: %i[distribution version disk_size push provision_path playbook]
  # store :config, accessors: %i[dist_version]
  store :config, accessors: %i[ansible_groups]

  before_save :ensure_directory
  after_save :write_it
  after_destroy :remove_tree

  def remove_tree
    execute_path.rmtree if execute_path.exist?
    config_path = save_path.split.first
    config_path.rmtree if config_path.exist?
  end

  parse_sources :project
  parse_scopes :build
  parse_options fixture_name: :build

  def packer_file
    'packer.json'
  end

  def full_name
    "#{project.name.tr('_', '-')}-#{packer_name}"
  end

  def render
    File.open(packer_file, 'w') { |f| f.write(to_packer) }
  end

  def execute_path
    Cnfs.paths.data.join(packer_name)
  end

  def to_packer
    JSON.pretty_generate(as_packer)
  end

  # rubocop:disable Metrics/AbcSize
  def as_packer
    {
      builders: builders.sort_by(&:order).each_with_object([]) { |o, ary| ary.append(o.to_packer) },
      provisioners: provisioners.sort_by(&:order).each_with_object([]) { |o, ary| ary.append(o.to_packer) },
      'post-processors': [post_processors.sort_by(&:order).each_with_object([]) { |o, ary| ary.append(o.to_packer) }]
    }
  end
  # rubocop:enable Metrics/AbcSize

  def provision_playbook
    provision_path.join(playbook || '')
  end

  def provision_path
    packages_path.join(super || '')
  end

  def as_save
    attributes.except('id', 'name', 'project_id', 'source_id').merge(source: source&.name) 
  end

  def ensure_directory
    save_path.split.first.mkpath unless save_path.split.first.exist?
  end

  def save_path
    Cnfs.project.paths.config.join('builds', name, "#{self.class.table_name.singularize}.yml")
  end

  def write_it
    execute_path.mkpath unless execute_path.exist?
    Dir.chdir(execute_path) do
      BuildGenerator.new([self], Cnfs.project.options).invoke_all
      render
      yield if block_given?
    end
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :project
        t.references :source
        t.string :config
        t.string :name
      end
    end
  end
end
