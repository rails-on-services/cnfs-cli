# frozen_string_literal: true

require 'active_model'

# module Cnfs::Concerns::ExecController
module Cnfs
  module Concerns
    module ExecController
      extend ActiveSupport::Concern

      included do
        extend ActiveModel::Callbacks
        include ActiveModel::AttributeAssignment

        attr_accessor :options, :args

        define_model_callbacks :execute
      end

      def initialize(**kwargs) = assign_attributes(**kwargs)

      # This method is invoked from Cnfs::Concerns::CommandController execute method
      # and invokes the target method wrapped in any defined callbacks
      def base_execute(method) = run_callbacks(:execute) { send(method) }

      # Implement with an around_execute :timer call in the controller
      def timer(&block) = Cnfs.with_timer('Command execution', &block)
    end
  end
end
