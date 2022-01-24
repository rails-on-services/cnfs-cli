# frozen_string_literal: true

# Common Functionallity for Component and Asset
module OneStack::Concerns
  module Parent
    extend ActiveSupport::Concern

    included do
      include SolidRecord::Model
      include OneStack::Concerns::Encryption
      include OneStack::Concerns::Interpolation
  
      store :config, coder: YAML

      validates :name, presence: true

      # after_create :create_node_record
      # after_update :update_node_record
      # after_destroy :destroy_node_record
    end

    def to_context() = as_interpolated

    def node_content() = as_json_encrypted

    # def create_node_record() = node_class.create_content(object: self)

    # def node_class() = self.class.reflect_on_association(:node).klass

    # Assets whose owner is Context are ephemeral so don't create/update a node
    # def update_node_record() = node.update_content(object: self)

    # def destroy_node_record() = node.destroy_content(object: self)

    # Log message at level warn appending the parent path to the message
    # def node_warn(node:, msg: [])
      # text = [msg].flatten.append("Source: #{node.rootpath}").join("\n#{' ' * 10}")
      # Cnfs.logger.warn(text)
    # end

    # def p_node?() = Node.source.eql?(:p_node)
    #   is_a?(Component) || owner.is_a?(Component)
    # end

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
