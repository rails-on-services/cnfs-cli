# frozen_string_literal: true

class TargetLayer < ApplicationRecord
  belongs_to :target
  belongs_to :layer
end

