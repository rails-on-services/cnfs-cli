# frozen_string_literal: true

class DeploymentTarget < ApplicationRecord
  belongs_to :deployment
  belongs_to :target
end

