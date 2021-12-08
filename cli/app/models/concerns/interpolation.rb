# frozen_string_literal: true

module Concerns
  module Interpolation
    extend ActiveSupport::Concern

    # TODO: Integrate these two methods
    def as_interpolated(method: :as_merged)
      self_hash = send(method).compact
      parent_hash = owner&.as_interpolated(method: method) || {}

      self_hash.deep_transform_values do |value|
        next value unless value.is_a? String

        value.cnfs_sub(default: self_hash, parent: parent_hash)
      end
    end

    def with_other(**kwargs)
      as_interpolated.deep_transform_values do |value|
        next value unless value.is_a? String

        value.cnfs_sub(**kwargs)
      end
    end
  end
end
