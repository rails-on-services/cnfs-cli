# frozen_string_literal: true

module SolidRecord
  class << self
    MAX_ID = (2**30) - 1

    attr_writer :path_column, :key_column, :reference_suffix

    # Default values for SolidRecord that are used in the Persistence Concern
    def path_column() = @path_column ||= 'path'

    def key_column() = @key_column ||= 'key'

    def reference_suffix() = @reference_suffix ||= 'name'

    def identify(path, key) = Zlib.crc32("#{path.keyname}/#{key}") % MAX_ID
  end

  module Persistence
    extend ActiveSupport::Concern

    class_methods do
      def load_content(path)
        disable_callbacks do
          formatted_assets(path).each do |key, values|
            hash = formatted_attributes(path, values).merge(solid_attributes(path.realpath, key))
            res = create(hash)
            puts(res.errors) unless res.persisted?
          end
        end
      end

      def formatted_assets(path) = path.singular? ? { SolidRecord.key_column => path.read_asset } : path.read_asset

      def formatted_attributes(_path, values) = values

      def solid_attributes(path, key)
        { 'id' => SolidRecord.identify(path, key), SolidRecord.path_column => path, SolidRecord.key_column => key }
      end

      def disable_callbacks
        skip_callback(*solid_record_callback)
        yield
        set_callback(*solid_record_callback)
      end

      def solid_record_callback() = %i[create after _create_asset_]
    end

    included do
      after_create :_create_asset_
      after_update :_update_asset_
      after_destroy :_destroy_asset_
    end

    def _create_asset_() = nil

    def to_solid() = pathname.singular? ? as_solid : { _key_ => as_solid }

    def as_solid() = as_json.except(*except_solid)

    def except_solid() = ['id', SolidRecord.path_column, SolidRecord.key_column]

    def pathname() = @pathname ||= Pathname.new(_path_)

    # TODO: rename method
    def gid() = SolidRecord.identify(_path_, _key_)

    def _path_() = send(SolidRecord.path_column)

    def _key_() = send(SolidRecord.key_column)

    def _update_asset_() = pathname.write_asset(content_to_write)

    def content_to_write() = pathname.singular? ? to_solid : pathname.read_asset.merge(to_solid)

    def _destroy_asset_
      if pathname.singular? || pathname.read_asset.keys.size.eql?(1)
        pathname.delete
      else
        pathname.write_asset(pathname.read_asset.except(_key_))
      end
    end
  end
end
