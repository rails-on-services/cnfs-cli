# frozen_string_literal: true

class BuilderGenerator < ApplicationGenerator
  attr_reader :blueprint

  private

  # Used by the ApplicationGenerator#plugin_paths
  def caller_path; 'builder' end

  def path(to = :templates)
    project.path(to: to)
  end
end
