# frozen_string_literal: true

class InfraRuntimeGenerator < ApplicationGenerator
  attr_accessor :resource

  def invoke_parent_methods
    generate_entity_manifests
    remove_stale_files
  end

  private

  def entity_name; :resource end

  def entities; resources end

  def views_path; super.join(target.provider.type.demodulize.underscore) end

  def path_type; :infra end
end
