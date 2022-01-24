# frozen_string_literal: true

# Common Functionallity for Component and Asset
module OneStack::Concerns
  module Generic
    extend ActiveSupport::Concern

    included do
      include SolidRecord::Model
      include OneStack::Concerns::Asset
      include OneStack::Concerns::Extendable
    end
  end
end
