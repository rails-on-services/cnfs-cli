# frozen_string_literal: true

class Runtime < ApplicationRecord
  include Concerns::Asset
  include Concerns::Operator

  has_many :runtime_services

  attr_accessor :services, :context_services

  store :config, accessors: %i[version]

  # This Operator manages target_type
  def target_type() = :services

  def self.add_columns(t)
    t.references :resource
  end
end
