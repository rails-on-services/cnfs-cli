# frozen_string_literal: true

class Builder < ApplicationRecord
  include Concerns::Asset
  include Concerns::Operator

  attr_accessor :images

  # This Operator manages target_type
  def target_type() = :images
end
