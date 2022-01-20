# frozen_string_literal: true

module SolidRecord
  module Associations
    extend ActiveSupport::Concern

    class_methods do
      # values is the hash of attributes that will be passed to create method
      def formatted_attributes(path, values)
        # puts name, path
        h = assn_names.each_with_object(values) do |assn_name, hash|
          # next unless (assn_value = hash["#{assn_name}_name"])
          if (assn_value = hash["#{assn_name}_name"])
          else
            if path.parent.directory?
              assn_value = path.parent.name
              # hash["#{assn_name}_name"] = assn_value
            else
              puts "assn_value not found for #{assn_name}"
              next
            end
          end

          p_path = parent(path)
          assn_id = identify(p_path, assn_value)
          puts p_path, assn_value, assn_id
          # binding.pry

          # assn_id = SolidRecord.identify(parent(path), assn_value)
          hash.merge!("#{assn_name}_id" => assn_id)
        end
        # puts '===='
        h
      end

      def parent(path)
        return path.parent.parent if path.singular?

        return path.parent if path.parent.classify.safe_constantize
        path.parent.parent
      end

      def assn_names() = reflect_on_all_associations(:belongs_to).map(&:name)
    end

    def except_solid() = super + self.class.assn_names.map { |name| "#{name}_id" }
  end

  # NOTE: The old Persistence Concern code
  module Persistence
    MAX_ID = (2**30) - 1

    extend ActiveSupport::Concern

    class_methods do
      def load_content(path)
        disable_callbacks do
          formatted_assets(path).each do |key, values|
            sa = if path.singular?
                   solid_attributes(path.parent.realpath, key)
                 else
                   solid_attributes(path.realpath, key)
                 end
            # puts name, path.realpath, sa
            # hash = formatted_attributes(path, values).merge(solid_attributes(path.realpath, key))
            hash = formatted_attributes(path, values).merge(sa)
            # puts '==='
            begin
              if (class_name = hash[inheritance_column]) && (klass = class_name.safe_constantize)
                ar = klass._create_callbacks # .select { |cb| cb.kind.eql?(:after) }
                # klass._create_callbacks
                # binding.pry if ar.any? # hash['kind'].eql?('Vpn')
              end
              res = create(hash)
              puts(res.errors) unless res.persisted?
            rescue ActiveRecord::SubclassNotFound => e
              puts "Error on #{path}"
            end
          end
        end
      end

      # def formatted_assets(path) = path.singular? ? { SolidRecord.key_column => path.read_asset } : path.read_asset
      def formatted_assets(path) = path.singular? ? { path.name => path.read_asset } : path.read_asset

      def formatted_attributes(_path, values) = values

      def solid_attributes(path, key)
        { 'id' => identify(path, key), SolidRecord.path_column => path, SolidRecord.key_column => key }
      end

      # Returns an deterministic integer ID for a record based on path and key value representing an object
      def identify(path, key) = Zlib.crc32("#{path.keyname}/#{key}") % MAX_ID

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
    def gid() = identify(pathname, _key_)

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
