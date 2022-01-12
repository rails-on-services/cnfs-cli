# frozen_string_literal: true

module SolidRecord
  module Persistence
    extend ActiveSupport::Concern

    included do
      after_create :create_node_record
      after_update :update_node_record
      after_destroy :destroy_node_record
    end

    def node_content
      raise NotImplementedError, 'duh'
    end

    def create_node_record() = node_class.create_content(object: self)

    # NOTE: Including class needs to declare the belongs_to :node
    # The spec that includes this concern should test that this belongs_to raises an error if it's missing
    # This concern could have a special belongs_to :node and add the column automatically
    # Or more like rails would be to have a generator that does the right thing
    # Both of these actions will take time which is not what I want to do now
    # However, it is more about getting the code encapsulated so have a think about it and see
    def node_class() = self.class.reflect_on_association(:node).klass

    # Assets whose owner is Context are ephemeral so don't create/update a node
    def update_node_record() = node.update_content(object: self)

    def destroy_node_record() = node.destroy_content(object: self)

    class_methods do
      def node_callbacks
        [
          %i[create after create_node_record],
          %i[update after update_node_record]
        ]
      end
    end
  end
end
