# frozen_string_literal: true

class TargetService < ApplicationRecord
  belongs_to :target
  belongs_to :service
end

