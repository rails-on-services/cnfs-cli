# frozen_string_literal: true

class Runtime < ApplicationRecord
  include Concerns::Asset
  include Concerns::PlatformRunner

  has_many :runtime_services, class_name: 'Runtime::Service'

  attr_accessor :services, :context_services

  store :config, accessors: %i[version], coder: YAML

  def self.add_columns(t)
    t.references :resource
    # TODO: Dependencies are handled by PlatformRunner and Platform
    t.string :dependencies
  end
end
