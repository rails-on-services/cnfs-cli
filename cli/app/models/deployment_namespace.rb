# frozen_string_literal: true

class DeploymentNamespace < ApplicationRecord
  belongs_to :deployment
  belongs_to :namespace
end
