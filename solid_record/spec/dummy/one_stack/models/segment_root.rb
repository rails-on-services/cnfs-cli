# frozen_string_literal: true

module OneStack
  class SegmentRoot < Component
    def owner_extension_path() = OneStack.config.paths.segments

    # Override superclass methods as this is the root class in the hierarchy
    def key() = @key ||= super || warn_key

    def key_name() = name

    def key_name_env() = OneStack.config.env.key_prefix

    def warn_key
      OneStack.logger.error("No encryption key found. Run 'onestack generate key'")
      nil
    end

    # Override Component to provide the 'root' paths and attrs
    def cache_path() = @cache_path ||= OneStack.config.cache_home.join(name)

    def data_path() = @data_path ||= OneStack.config.data_home.join(name)

    def attrs() = @attrs ||= [name]

    def struct() = OpenStruct.new(segment_type: 'root', name: name)

    def name() = 'application' # OneStack.application.name

    def tree_label() = name

    class << self
      def unknown_document_type() = OneStack::Component # For SolidRecord to determine the owner class type
    end
  end
end
