# frozen_string_literal: true

module Concerns
  module Interpolation
    extend ActiveSupport::Concern

    def cnfs_sub
      return as_json unless owner

      owner_hash = owner.cnfs_sub
      this_hash = as_json.compact.deep_transform_values do |value|
        value.cnfs_sub(owner_hash, owner_hash['config'])
      end

      # binding.pry
      # this_hash = as_json.deep_transform_values { |value| value&.cnfs_sub(owner_hash) }
      owner_hash.merge(this_hash)
    end
  end
end