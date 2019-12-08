# frozen_string_literal: true

class ApplicationLayer < ApplicationRecord
  belongs_to :application
  belongs_to :layer
end

