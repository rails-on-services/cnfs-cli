# frozen_string_literal: true

# Common functionality for Component and Asset
module OneStack
  module Concerns::Parent
    extend ActiveSupport::Concern

    class_methods do
      # Disable storing database primary and foreign keys to yaml
      # All references are determined dynamically when the context builds the assets
      # Storing keys in yaml would be confusing to user and will cause problems as yaml content changes and IDs change
      # Any nested stored_attributes should not be serialized as the root is already serialized
      def except_solid
        (super + %w[owner_type] + column_names.select { |n| n.end_with?('_id') } +
         (stored_attributes.keys.map(&:to_s) - column_names)).uniq
      end
    end

    included do
      include SolidRecord::Model
      # TODO: Test and refactor Interpolation
      include SolidSupport::Interpolation

      # NOTE: These methods do not work when declared in class_methods block
      def self.owner_association_name() = :owner
      def self.key_column() = 'name'
  
      store :config, coder: YAML

      validates :name, presence: true
    end

    # TODO: Simplify interpolated
    def to_context() = as_interpolated

    # Convenience methods for cache_* and data_* for clarity in calling code
    def cache_file_read() = local_file_read(path: cache_file)

    def data_file_read() = local_file_read(path: data_file)

    def local_file_read(path:) = path.exist? ? (YAML.load_file(path) || {}) : {}

    def cache_file_write(**values) = local_file_write(path: cache_file, values: values)

    def data_file_write(**values) = local_file_write(path: data_file, values: values)

    def local_file_write(path:, values:)
      path.parent.mkpath
      File.open(path, 'w') { |f| f.write(values.to_yaml) }
    end
  end
end
