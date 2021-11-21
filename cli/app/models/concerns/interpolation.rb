# frozen_string_literal: true

module Concerns
  module Interpolation
    extend ActiveSupport::Concern

    def as_interpolated(method: :as_merged)
      this_hash = send(method).compact
      parent_hash = owner&.as_interpolated(method: method) || {}

      this_hash.deep_transform_values do |value|
        next value unless value.is_a? String

        value.cnfs_sub(default: this_hash, parent: parent_hash)
      end
    end
  end
end
