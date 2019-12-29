# frozen_string_literal: true

# Application has_many :services
# Application has_many :resources
# Deployment is a set of targets and an application

class Deployment < ApplicationRecord
  belongs_to :application
  has_many :deployment_targets
  has_many :targets, through: :deployment_targets

  store :config, accessors: %i[base_path], coder: YAML

  validates :base_path, presence: true
  validates :name, presence: true

  def deploy_path; root.join(base_path) end

  def root; Pathname.new(Dir.pwd) end
end
