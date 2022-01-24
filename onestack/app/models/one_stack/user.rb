# frozen_string_literal: true

module OneStack
  class User < ApplicationRecord
    include OneStack::Concerns::Generic
    def self.key_column() = 'name'

    class << self
      def add_columns(t)
        t.string :role
        t.string :full_name
      end
    end
  end
end
