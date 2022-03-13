# frozen_string_literal: true

module OneStack
  class SegmentRoot < Component
    def owner_extension_path() = OneStack.config.paths.segments

    # Override superclass methods as this is the root class in the hierarchy
    def key() = @key ||= super || warn_key

    def key_name() = name

    # TODO: change from CNFS to OS
    def key_name_env() = 'CNFS_KEY'

    def warn_key
      OneStack.logger.error("No encryption key found. Run 'cnfs project generate_key'")
      nil
    end

    # Override Component to provide the 'root' paths and attrs
    def cache_path() = @cache_path ||= OneStack.config.cache_home.join(name)

    def data_path() = @data_path ||= OneStack.config.data_home.join(name)

    def attrs() = @attrs ||= [name]

    def struct() = OpenStruct.new(segment_type: 'root', name: name)

    def name() = OneStack.application.name

    class << self
      def unknown_document_type() = OneStack::Component # For SolidRecord to determine the owner class type
    end
  end
end
