# frozen_string_literal: true

module OneStack
  class User < ApplicationRecord
    include Concerns::Generic

    attr_encrypted :test

    class << self
      def add_columns(t)
        t.string :role
        t.string :test
        t.string :full_name
      end
    end
  end
end
