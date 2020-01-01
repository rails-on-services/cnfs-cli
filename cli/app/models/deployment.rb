# frozen_string_literal: true

class Deployment < ApplicationRecord
  belongs_to :application
  belongs_to :target

  store :config, accessors: %i[base_path], coder: YAML

  validates :base_path, presence: true
  validates :name, presence: true
end
