# frozen_string_literal: true

module SolidRecord
  module Associations
    extend ActiveSupport::Concern

    included do
      validate :dynamic_association_types
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    def dynamic_association_types
      # return unless Node.source.eql?(:asset)

      self.class.belongs_to_names.each do |attribute|
        # In order to validate there must be a defined association and a value or array of values to check against
        next unless respond_to?(attribute.to_sym) && (available_types = valid_types[attribute])

        available_types = [available_types] if available_types.is_a? String
        actual_type = send(attribute.to_sym)&.type
        next if available_types.include?(actual_type)

        errors.add(attribute, "type is '#{actual_type}', but must be one of: #{available_types.join(', ')}")
      end
    end

    def valid_types
      {}.with_indifferent_access
    end

    # rubocop:disable Metrics/BlockLength
    # rubocop:disable Metrics/PerceivedComplexity
    class_methods do
      def with_node_callbacks_diabled
        node_callbacks.each { |callback| skip_callback(*callback) }
        yield
        node_callbacks.each { |callback| set_callback(*callback) }
      end

      def update_associations(context)
        return if belongs_to_names.size.zero?

        with_node_callbacks_diabled { dynamic_update(context) }
      end

      # rubocop:disable Metrics/MethodLength
      def dynamic_update(context)
        res_msg = "#{table_name.classify} not configured: "

        context.send(table_name).each do |asset|
          update_hash = belongs_to_names.each_with_object({}) do |attribute, hash|
            # STI classes have the field but do do not implement the belongs_to, e.g. only some resources hace runtime
            next unless asset.respond_to?(attribute.to_sym)

            assn = context.send(attribute.pluralize.to_sym)
            name = asset.send("#{attribute}_name".to_sym)
            if name
              if (obj = assn.find_by(name: name))
                hash[attribute] = obj
              else
                # Cnfs.logger.warn("#{res_msg}#{asset.name}" \
                #                  "\n#{' ' * 10}#{attribute.capitalize} '#{name}' is not available in this segment" \
                #                  "\n#{' ' * 10}Available #{attribute.pluralize}: #{assn.pluck(:name).join(', ')}")
              end

            # No records of the configured assocation type are available
            elsif assn.size.eql?(1) # There is exactly one record availalble so use it
              obj = assn.first
              hash[attribute] = obj
              hash["#{attribute}_name"] = obj.name
            # TODO: this
            # needs to reference the cnfs_sub hash rather than just the component's attribute which is not merged
            # Consolidate the logging to a single method
            # For each asset track the list of files that were merged to make the one asset
            elsif (name = context.component.send("#{attribute}_name")) # Use the component default
              if (obj = assn.find_by(name: name))
                hash[attribute] = obj
                hash["#{attribute}_name"] = obj.name
              else
                # Cnfs.logger.warn("#{res_msg}#{asset.name}" \
                #                  "\n#{' ' * 10}Default #{attribute} #{name} not found" \
                #                  "\n#{' ' * 10}Source: #{context.component.parent.rootpath}")
              end
            end
          end
          asset.update(update_hash)
          next unless asset.errors.any?

          Cnfs.logger.warn(asset.errors.full_messages.unshift("#{res_msg}#{asset.name}").join("\n#{' ' * 10}"))
        end
      end

      def belongs_to_names
        @belongs_to_names ||= reference_columns.group_by do |n|
                                n.split('_').first
                              end .select { |_k, v| v.size.eql?(2) }.keys
      end

      def reference_columns
        @reference_columns ||= column_names.select { |n| n.end_with?('_id') || n.end_with?('_name') }
      end
    end
  end
end
