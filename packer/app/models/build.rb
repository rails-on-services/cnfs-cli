# frozen_string_literal: true

class Build < ApplicationRecord
  include Concerns::BelongsToProject

  belongs_to :source, class_name: 'Build', required: false

  store :config, accessors: %i[distribution version disk_size push provision_path playbook]
  store :config, accessors: %i[dist_version]

  parse_sources :project

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
    attributes.except('id', 'name', 'source_id').merge({
                                                         source: source&.name
                                                       })
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :project
        t.references :source
        t.string :name
        t.string :config
      end
    end
  end
end
