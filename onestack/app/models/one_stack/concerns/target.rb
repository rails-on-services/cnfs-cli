# frozen_string_literal: true

module OneStack
  module Concerns::Target
    extend ActiveSupport::Concern

    included do
      include Concerns::Asset

      # Targets can use command_queue to execute commands on the system, e.g. docker exec ...
      # TODO: Implement in a model and test
      attr_accessor :command_queue

      define_model_callbacks(*operator.target_callbacks, only: %i[before after]) if respond_to?(:operator)

      include SolidSupport::Extendable if defined?(SolidSupport)
    end
  end
end
