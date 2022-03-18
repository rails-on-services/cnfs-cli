# frozen_string_literal: true

module OneStack
  module Concerns::Asset
    extend ActiveSupport::Concern

    included do
      include Concerns::Parent

      belongs_to :owner, polymorphic: true, required: true

      scope :inheritable, -> { where(inherit: [true, nil], abstract: [false, nil]).order(:id) }
      scope :enabled, -> { where(enable: [true, nil], abstract: [false, nil]) }

      # Takes a hash. Examples: { users: [joe, bob] } or { plan: vpc }
      # and based on key name determines if the hash is appropriate to be applied to the model association
      # if not it provides an empty hash to .where which has no impact on the generated SQL
      scope :filter_by, lambda { |args|
        args = args.with_indifferent_access
        conditions = args[table_name] || args[table_name.singularize]
        conditions_hash = conditions ? { name: conditions } : {}
        where(conditions_hash)
      }

      # Takes an array of tags in format: ["country=us", "state=ny"]
      scope :with_tags, lambda { |tags|
        return self unless tags

        ret_val = self
        tags.each do |item|
          name, value = item.split('=')
          ret_val = ret_val.where('tags LIKE ?', "%#{name}: #{value}%")
        end
        ret_val
      }

      store :tags, coder: YAML

      delegate :encryption_key, to: :owner

      before_validation :cli_owner, if: -> { SolidRecord.status.loaded? && OneStack.config.cli.mode }

      validate :dynamic_association_types, if: -> { SolidRecord.status.loaded? }
    end

    def cli_owner() = self.owner ||= Navigator.current.context.component

    def as_merged
      return as_solid unless from && (source = owner.send(self.class.table_name).find_by(name: from))

      source.as_solid.except('abstract').deep_merge(as_json)
    end

    def dynamic_association_types
      return # unless Node.source.eql?(:asset)

      self.class.belongs_to_names.each do |attribute|
        # In order to validate there must be a defined association and a value or array of values to check against
        next unless respond_to?(attribute.to_sym) && (available_types = valid_types[attribute])

        available_types = [available_types] if available_types.is_a? String
        actual_type = send(attribute.to_sym)&.type
        next if available_types.include?(actual_type)

        errors.add(attribute, "type is '#{actual_type}', but must be one of: #{available_types.join(', ')}")
      end
    end

    def valid_types() = {}.with_indifferent_access

    # TODO: Include SolidSupport::TreeView and override as_tree
    def tree_label() = [name, type&.deconstantize].compact.join(': ').gsub('::', ' ')

    # TODO: Implement when option vebose is paased in
    def tree_name_verbose
      %w[inherit enable].each_with_object([name]) do |v, ary|
        ary.append("(#{v})") if v.nil? || v
      end.join(' ')
    end

    def cache_file() = @cache_file ||= owner.cache_path.join(asset_type, "#{name}.yml")

    def data_file() = @data_file ||= owner.data_path.join(asset_type, "#{name}.yml")

    # def asset_type() = self.class.name.demodulize.underscore.pluralize
    def asset_type() = self.class.table_name

    class_methods do
      def update_associations(context)
        return unless belongs_to_names.size.zero?

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
                # Hendrix.logger.warn("#{res_msg}#{asset.name}" \
                #                  "\n#{' ' * 10}#{attribute.capitalize} '#{name}' is not available in this segment" \
                #                  "\n#{' ' * 10}Available #{attribute.pluralize}: #{assn.pluck(:name).join(', ')}")
              end

            # No records of the configured assocation type are available
            elsif assn.size.eql?(1) # There is exactly one record availalble so use it
              obj = assn.first
              hash[attribute] = obj
              hash["#{attribute}_name"] = obj.name
            # TODO:
            # This needs to reference the cnfs_sub hash rather than just the component's attribute which is not merged
            # Consolidate the logging to a single method
            # For each asset track the list of files that were merged to make the one asset
            elsif (name = context.component.send("#{attribute}_name")) # Use the component default
              if (obj = assn.find_by(name: name))
                hash[attribute] = obj
                hash["#{attribute}_name"] = obj.name
              else
                # Hendrix.logger.warn("#{res_msg}#{asset.name}" \
                #                  "\n#{' ' * 10}Default #{attribute} #{name} not found" \
                #                  "\n#{' ' * 10}Source: #{context.component.parent.rootpath}")
              end
            end
          end
          asset.update(update_hash)
          next unless asset.errors.any?

          OneStack.logger.warn(asset.errors.full_messages.unshift("#{res_msg}#{asset.name}").join("\n#{' ' * 10}"))
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

      def table_mod(method) = table_mods.append(method)

      def table_mods() = @table_mods ||= []

      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.string :name
          t.string :type
          t.boolean :abstract
          t.boolean :enable
          t.boolean :inherit
          t.string :from
          t.references :owner, polymorphic: true
          t.string :config
          t.string :tags
          add_columns(t) if respond_to?(:add_columns)
          table_mods.each { |mod| send(mod, t) }
        end
      end
    end
  end
end
