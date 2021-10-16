# frozen_string_literal: true

class Namespace < ApplicationRecord
  include Concerns::Component
  # include Concerns::Key
  # include Concerns::HasEnvs
  # include Concerns::Taggable


  # delegate :project, :runtime, to: :environment

  store :config, accessors: %i[main], coder: YAML

  # parse_scopes :namespace
  # parse_sources :project, :user
  # parse_options fixture_name: :namespace

  # Override to provide a path alternative to config/table_name.yml
  # def save_path
  #   Cnfs.project.paths.config.join('environments', environment.name, name, 'namespace.yml')
  # end

  # def user_save_path
  #   Cnfs.user_root.join(Cnfs.config.name, Cnfs.paths.config, 'environments', environment.name, name, 'namespace.yml')
  # end

  def as_save
    attributes.slice('config', 'name', 'tags')
  end

  class << self
    def add_columns(t)
      # t.string :envs
      t.string :key
      # t.string :tags
    end
  end
end
