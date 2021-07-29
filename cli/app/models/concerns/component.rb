# frozen_string_literal: true

module Concerns
  module Component
    extend ActiveSupport::Concern

    included do
      has_many :services, as: :owner
      has_many :resources, as: :owner

      default_scope { where(context: Cnfs.context) }
    end
  end
end
