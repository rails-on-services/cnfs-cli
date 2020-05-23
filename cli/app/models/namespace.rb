# frozen_string_literal: true

class Namespace < ApplicationRecord
  has_many :target_namespaces
  has_many :targets, through: :target_namespaces
  has_many :deployments
  has_many :applications, through: :deployments
end
