# frozen_string_literal: true

class Context < ApplicationRecord
  belongs_to :target
  belongs_to :application

  def config(args); to_args.merge(args) end

  def to_args
    {
      profile_name: name,
      namespace_name: namespace,
      service_names: YAML.load(self[:services] || '') || [],
      resource_names: YAML.load(self[:resources] || '') || [],
      tag_names: YAML.load(self[:tags] || '') || [],
      target_name: target&.name,
      application_name: application&.name
    }.stringify_keys
  end
end
