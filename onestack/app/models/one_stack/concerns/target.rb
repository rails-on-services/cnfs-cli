# frozen_string_literal: true

module OneStack::Concerns
  module Target
    extend ActiveSupport::Concern

    included do
      include OneStack::Concerns::Asset

      # Targets can use command_queue to execute commands on the system, e.g. docker exec ...
      # TODO: Implement in a model and test
      attr_accessor :command_queue

      define_model_callbacks(*operator.target_callbacks, only: %i[before after]) if respond_to?(:operator)

      include Hendrix::Extendable
    end
  end
end
