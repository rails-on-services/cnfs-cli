# frozen_string_literal: true

class Environment < ApplicationRecord
  def values; options_hash(:values) end
  def to_env; values.to_env end


  def self.schema
    {
      type: 'object',
      properties: {
        redis_url: {
          type: 'string'
        }
      }
    }.with_indifferent_access
  end
end
