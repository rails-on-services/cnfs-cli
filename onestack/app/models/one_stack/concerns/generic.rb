# frozen_string_literal: true

# Functionality for Asset models that are not Operators or Targets
module OneStack
  module Concerns::Generic
    extend ActiveSupport::Concern

    included do
      include SolidRecord::Model
      include Concerns::Asset
      include SolidSupport::Extendable if defined?(SolidSupport)
    end
  end
end
