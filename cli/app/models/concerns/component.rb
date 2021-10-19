# frozen_string_literal: true

module Concerns
  module Component
    extend ActiveSupport::Concern

    included do
      belongs_to :parent, class_name: 'Node'
      belongs_to :context

      if (idx = Cnfs.config.orders.index(table_name))
        # TODO: after changing this to a class then declare a has_many :components which is self referencing like Node
        belongs_to :owner, class_name: Cnfs.config.order[idx - 1].classify if idx.positive?
        # belongs_to Cnfs.config.order[idx - 1].to_sym if idx.positive?
        # alias_method :owner, Cnfs.config.order[idx - 1].to_sym if idx.positive?

        # Cnfs.config.orders.each_index do |i|
        #   next if i <= idx
        #
        #   association = Cnfs.config.orders[i].to_sym
        #   has_many association if i == idx + 1
        #   next if i == idx + 1
        #
        #   has_many association, through: Cnfs.config.orders[i - 1].to_sym
        #   break if i == Cnfs.config.orders.size - 1
        # end
      end

      # Pluralized resource names are declared as a has_many
      Cnfs.config.asset_names.select{ |name| name.pluralize.eql?(name) }.each do |asset_name|
        has_many asset_name.to_sym, as: :owner
      end

      # Cnfs.config.asset_names.each do |asset|
      #   next unless asset.pluralize.eql?(asset)
      #
      #   has_many asset.to_sym, as: :owner
      # end

      store :config, coder: YAML

      validates :name, presence: true
    end

    # updates this component's context and it's owner's context (recursive until owner is nil)
    def update_context(context:)
      update(context: context)
      owner&.update_context(context: context)
    end

    def runtime
      resource&.runtime
    end

    # Scan all resources for a runtime association
    # If none is found then recursively call the owning component looking for a runtime
    # If none or multiple runtimes are found log a warning and return nil
    def resource
      runtime_resources = resources.select(&:runtime)
      size = runtime_resources.size
      if size.zero?
        Cnfs.logger.warn('No defined runtimes') if owner.nil?
        owner&.resource
      elsif size.eql?(1)
        runtime_resources.first
      else
        Cnfs.logger.warn("Multiple defined runtimes found in: #{runtime_resources.map(&:name).join(' ')}")
      end
    end

    class_methods do
      def child_component_class
        if (idx = Cnfs.config.orders.index(table_name))
          # puts table_name
          # binding.pry
          Cnfs.config.order[idx + 1].classify
        else
          # binding.pry
        end
      end

      def create_table(schema)
        schema.create_table table_name, force: true do |t|
          t.references :parent
          t.references :context
          t.references :owner
          # if (idx = Cnfs.config.orders.index(table_name)) && idx.positive?
          #   t.references Cnfs.config.order[idx - 1]
          # end
          t.string :name
          t.string :config
          add_columns(t)
        end
      end
    end
  end
end
