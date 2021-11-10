# frozen_string_literal: true

module Concerns
  module Interpolate
    extend ActiveSupport::Concern

    def cnfs_sub
      return as_json unless owner

      owner_hash = owner.cnfs_sub
      this_hash = as_json.compact.deep_transform_values do |value|
        value.cnfs_sub(owner_hash, owner_hash['config']) #, skip_raise: true) }
      end

      # binding.pry
      # this_hash = as_json.deep_transform_values { |value| value&.cnfs_sub(owner_hash) } #, skip_raise: true) }
      owner_hash.merge(this_hash)
    end
  end
end
