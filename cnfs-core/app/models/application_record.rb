# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Provides a default empty hash to validate against
  # Override in model to validate against a specific schema
  def self.schema; {} end

  # pass in a schema or uses the class default schema
  # usage: validator.valid?(payload hash)
  # See: https://github.com/davishmcclurg/json_schemer
  def validator(schema = self.class.schema); JSONSchemer.schema(schema) end

  def environment; options_hash(:environment) end
  def config; options_hash(:config) end

  def options_hash(attr)
    @options_hash ||= {}
    @options_hash[attr] ||= options(attr)
  end

  def options(attr)
    return Config::Options.new unless yaml = self[attr.to_sym]
    Config::Options.new.merge!(YAML.load(yaml))
  end
end
