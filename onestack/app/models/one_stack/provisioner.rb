# frozen_string_literal: true

module OneStack
  class Provisioner < ApplicationRecord
    # Define target and commands before including Operator Concern
    class << self
      def target() = :plans

      def commands() = %i[deploy undeploy]
    end

    include OneStack::Concerns::Operator

    # Assigned in Operator#execute
    attr_accessor :plans

    before_execute :generate
  end
end
