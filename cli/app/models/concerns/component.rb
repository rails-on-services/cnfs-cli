# frozen_string_literal: true

module Concerns
  module Component
    extend ActiveSupport::Concern

    included do
      # belongs_to :builder, optional: true

      has_many :services, as: :owner
      has_many :resources, as: :owner

      default_scope { where(context: Cnfs.context) }
    end

    class_methods do
      def create_table(schema)
        binding.pry
      end
    end
  end
end
