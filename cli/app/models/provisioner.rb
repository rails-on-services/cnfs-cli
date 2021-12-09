# frozen_string_literal: true

class Provisioner < ApplicationRecord
  include Concerns::Asset
  include Concerns::Operator

  # Resources assigned by the context
  attr_accessor :plans # , :context_plans

  # Physical join table managed by the Provisioner
  has_many :provisioner_resources

  # store :config, accessors: %i[version], coder: YAML

  before_execute :generate

  def target() = :plans

  def self.commands() = %i[deploy]
end
