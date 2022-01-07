# frozen_string_literal: true

class ApplicationRecord < Cnfs::ApplicationRecord
  self.abstract_class = true

  # by default rails does not serialize the type field
  def as_json
    super.merge(type_json).except(*except_json).compact
  end

  def type_json
    has_attribute?(:type) ? { 'type' => type } : {}
  end

  # TODO: Maybe this should move to parent concern?
  def except_json() = self.class.except_json

  # Disable storing database primary and foreign keys to yaml
  # All references are determined dynamically when the context builds the assets
  # Storing keys in yaml would be confusing to user and will cause problems as yaml content changes and IDs change
  # Any nested stored_attributes should not be serialized as the root is already serialized
  def self.except_json
    %w[id name owner_type] + column_names.select { |n| n.end_with?('_id') } +
      (stored_attributes.keys.map(&:to_s) - column_names)
  end
end
