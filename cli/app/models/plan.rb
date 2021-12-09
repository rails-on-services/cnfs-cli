# frozen_string_literal: true

# A Plan defines one or more resources for a Provisioner to create on the target Provider
class Plan < ApplicationRecord
  def self.operator() = Provisioner

  include Concerns::Target

  belongs_to :provider
  belongs_to :provisioner

  has_many :resources

  class << self
    def add_columns(t)
      t.references :provider
      t.string :provider_name
      t.references :provisioner
      t.string :provisioner_name
    end
  end
end
