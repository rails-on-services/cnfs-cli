# frozen_string_literal: true

class ProvisionerGenerator < ApplicationGenerator
  attr_reader :resource

  private

  # Used by the ApplicationGenerator#plugin_paths
  def caller_path() = 'builder'

  def path(to = :templates)
    binding.pry
    project.path(to: to)
  end
end
