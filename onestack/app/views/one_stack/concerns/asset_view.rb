# frozen_string_literal: true

module OneStack::Concerns
  module AssetView
    extend ActiveSupport::Concern

    included do
      include ParentView
      # include Concerns::Extendable
    end
  end
end
