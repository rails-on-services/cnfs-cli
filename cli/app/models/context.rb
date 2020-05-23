# frozen_string_literal: true

class Context < ApplicationRecord
  belongs_to :namespace
  belongs_to :deployment
  belongs_to :application

  has_many :context_targets
  has_many :targets, through: :context_targets
  has_many :context_services
  has_many :services, through: :context_services

  # def config(args)
  #   to_args.merge(args.stringify_keys || {})
  # end

  # def to_args
  #   {
  #     context_name: name,
  #     service_names: YAML.safe_load(self[:services] || '') || [],
  #     resource_names: YAML.safe_load(self[:resources] || '') || [],
  #     tag_names: YAML.safe_load(self[:tags] || '') || [],
  #     target_name: target&.name,
  #     application_name: application&.name,
  #     namespace_name: namespace&.name
  #   }.stringify_keys
  # end
end
