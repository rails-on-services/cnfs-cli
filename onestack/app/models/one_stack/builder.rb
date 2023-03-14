# frozen_string_literal: true

module OneStack
  class Builder < ApplicationRecord
    # Define target and commands before including Operator Concern
    class << self
      def target() = :images

      def commands() = %i[build push pull test]
    end

    include OneStack::Concerns::Operator

    # Assigned in Operator#execute
    attr_accessor :images

    before_execute :generate
  end
end
