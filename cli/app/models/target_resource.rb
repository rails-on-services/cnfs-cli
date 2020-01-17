# frozen_string_literal: true

class TargetResource < ApplicationRecord
  belongs_to :target
  belongs_to :resource
end

