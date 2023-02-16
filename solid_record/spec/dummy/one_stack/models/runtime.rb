# frozen_string_literal: true

module OneStack
  class Runtime < ApplicationRecord
    # Define target and commands before including Operator Concern
    class << self
      def target() = :services

      def commands() = %i[attach start stop restart terminate]
    end

    include OneStack::Concerns::Operator

    # Assigned in Operator#execute
    attr_accessor :resource, :services

    store :config, accessors: %i[version]

    before_execute :generate

    class << self
      def add_columns(t)
        t.references :resource
      end
    end
  end
end
