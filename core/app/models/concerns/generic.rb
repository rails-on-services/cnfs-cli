# frozen_string_literal: true

# Common Functionallity for Component and Asset
module Concerns
  module Generic
    extend ActiveSupport::Concern

    included do
      include Concerns::Asset
      include Concerns::Extendable
    end
  end
end
