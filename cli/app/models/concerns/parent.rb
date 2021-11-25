# frozen_string_literal: true

module Concerns
  module Parent
    extend ActiveSupport::Concern

    included do
      # Plugins that have an appropriately named A/S Concern will be automatically included
      #
      # Example:
      # The terraform plugin adds methods to the Resource model by including A/S Concern in the module
      # Terraform::Resource declared in file CnfsCli::Terraform.gem_root/app/models/terraform/resource.rb
      Cnfs.modules_for(mod: CnfsCli, klass: self).each { |mod| include mod }

      store :config, coder: YAML

      validates :name, presence: true

      after_create :create_node
      after_update :update_node
      after_destroy :destroy_node
    end

    def to_context() = as_interpolated

    # Assets whose owner is Context are ephemeral so don't create/update a node
    def create_node
      create_parent(type: parent_type, owner: self) # if node?
    end

    def update_node
      parent.update(owner: self) # if node?
    end

    def destroy_node
      parent.destroy # if node?
    end

    def parent_type
      is_a?(Component) ? 'Node::Component' : 'Node::Asset'
    end

    # Log message at level warn appending the parent path to the message
    def node_warn(node:, msg: [])
      text = [msg].flatten.append("Source: #{node.rootpath}").join("\n#{' ' * 10}")
      Cnfs.logger.warn(text)
    end

    # def node?
    #   is_a?(Component) || owner.is_a?(Component)
    # end

    class_methods do
      def node_callbacks
        [
          %i[create after create_node],
          %i[update after update_node]
        ]
      end
    end
  end
end
