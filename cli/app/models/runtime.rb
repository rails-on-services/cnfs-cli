# frozen_string_literal: true

class Runtime < ApplicationRecord
  include Concerns::Asset
  include Concerns::Operator

  has_many :runtime_services

  attr_accessor :services, :context_services

  store :config, accessors: %i[version]

  before_execute :generate

  def target() = :services

  def self.add_columns(t)
    t.references :resource
  end
end
