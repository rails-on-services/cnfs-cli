# frozen_string_literal: true

class Runtime < ApplicationRecord
  has_many :targets

  # Attributes configured by the command object
  attr_accessor :cmd, :deployment, :application, :target

  # Method invoked by the generate command
  # def generate(deployment, target)
  #   generator.deployment = deployment
  #   generator.target = target
  #   generator.invoke
  # end
end
