# frozen_string_literal: true

module Concerns
  module AssetView
    extend ActiveSupport::Concern

    included do
      include Concerns::ParentView
      # include Concerns::Extendable
    end
  end
end
