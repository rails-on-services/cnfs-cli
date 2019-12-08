# frozen_string_literal: true

class Layer < ApplicationRecord
  has_many :application_layers
  has_many :applications, through: :application_layers
  has_many :target_layers
  has_many :targets, through: :target_layers
  has_many :services
end
