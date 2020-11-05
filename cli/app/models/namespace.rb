# frozen_string_literal: true

class Namespace < ApplicationRecord
  belongs_to :key

  validates :name, presence: true
  delegate :encrypt, :decrypt, to: :key
end
