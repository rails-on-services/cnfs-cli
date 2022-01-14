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
          assn_id = SolidRecord.identify(p_path, assn_value)
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
end
