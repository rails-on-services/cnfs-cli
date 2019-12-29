# frozen_string_literal: true

class Service < ApplicationRecord
  has_many :service_tags
  has_many :tags, through: :service_tags

  def test_commands(options = nil); [] end
end
