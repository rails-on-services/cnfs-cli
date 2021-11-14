# frozen_string_literal: true

module Concerns
  module Parent
    extend ActiveSupport::Concern

    included do
      store :config, coder: YAML

      validates :name, presence: true

      after_create :create_node
      after_update :update_node
      after_destroy :destroy_node
    end

    # Assets whose owner is Context are ephemeral so don't create/update a node
    def create_node
      create_parent(type: parent_type, owner: self) if node?
    end

    def update_node
      parent.update(owner: self) if node?
    end

    def destroy_node
      parent.destroy if node?
    end

    def parent_type
      is_a?(Component) ? 'Node::Component' : 'Node::Asset'
    end

    def node?
      is_a?(Component) || owner.is_a?(Component)
    end

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
