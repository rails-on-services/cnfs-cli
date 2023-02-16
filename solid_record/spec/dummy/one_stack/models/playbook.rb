# frozen_string_literal: true

module OneStack
  class Playbook < ApplicationRecord
    include OneStack::Concerns::Target

    class << self
      def add_columns(t)
        t.string :configurator_name
        t.references :configurator
      end
    end
  end
end
