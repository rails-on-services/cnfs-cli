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

  def bump(type)
    type = type.to_s.downcase
    return unless %w[major minor pach pre].include?(type)

    Dir.chdir(Cnfs.paths.tmp) do
      File.open('VERSION', 'w') { |f| f.write(version) }
      nv = Bump::Bump.next_version(type)
      FileUtils.rm('VERSION')
      nv
    end
  end

  def as_save
    attributes.except('id', 'name', 'project_id', 'source_id').merge(source: source&.name)
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
