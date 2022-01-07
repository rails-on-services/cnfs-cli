# frozen_string_literal: true

# A Plan defines one or more resources for a Provisioner to create on the target Provider
class Plan < ApplicationRecord
  # Define operator before inclding Concerns::Target
  def self.operator() = Provisioner

  include Concerns::Target

  belongs_to :provider
  belongs_to :provisioner

  # NOTE: This is used by Provisioner to CRUD resources after a command, e.g. deploy, destroy, is run
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
