# frozen_string_literal: true

module SolidRecord
  # Specific Element type which represents a Document
  class RootElement < Element
    MAX_ID = (2**30) - 1

    belongs_to :document

    delegate :pathname, to: :document

    def root() = self

    # Returns an deterministic integer ID for a record based on path and key value representing an object
    def identify(key:, type: nil)
      type ||= pathname.name
      key_name = pathname.realpath.parent.join(type, key).to_s
      Zlib.crc32(key_name) % MAX_ID
      # debug("#{type}: #{key}", "from: #{pathname.realpath}", key_name, ret_val)
    end

    def __create_element
      # TODO: Determine where to write the element
      # binding.pry
    end

    def __update_element
      # TODO: call document.write
      # binding.pry
    end

    # def content_to_write() = pathname.singular? ? to_solid : pathname.read_asset.merge(to_solid)

    def __destroy_element
      # TODO: call document.write
      #   if pathname.singular? || pathname.read_asset.keys.size.eql?(1)
      #     pathname.delete
      #   else
      #     pathname.write_asset(pathname.read_asset.except(_key_))
      #   end
    end
  end
end
