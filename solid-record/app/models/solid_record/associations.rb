# frozen_string_literal: true

module SolidRecord
  module Associations
    extend ActiveSupport::Concern

    class_methods do
      def formatted_attributes(path, values)
        assn_names.each_with_object(values) do |assn_name, hash|
          assn_id = SolidRecord.identify(parent(path), hash["#{assn_name}_name"])
          hash.merge!("#{assn_name}_id" => assn_id)
        end
      end

      def parent(path) = path.singular? ? path.parent.parent : path.parent

      def assn_names() = reflect_on_all_associations(:belongs_to).map(&:name)
    end

    def except_solid() = super + self.class.assn_names.map{ |name| "#{name}_id" }
  end
end
