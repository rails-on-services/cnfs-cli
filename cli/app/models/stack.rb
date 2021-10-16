# frozen_string_literal: true

class Stack < ApplicationRecord
  include Concerns::Component
  # include Concerns::Key
  # include Concerns::HasEnvs

  def as_save
    attributes.slice('config', 'context', 'key')
  end

  class << self
    def add_columns(t)
      t.string :context
      t.string :key
      # t.references :builder
      # t.string :config
      # t.string :dns_root_domain
      # t.string :envs
    end
  end
end
