# frozen_string_literal: true

class Namespace < ApplicationRecord
  include Concerns::Component
  # include Concerns::Key
  # include Concerns::HasEnvs
  # include Concerns::Taggable

  store :config, accessors: %i[main], coder: YAML

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
