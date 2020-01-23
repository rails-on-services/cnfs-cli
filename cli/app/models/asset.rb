# frozen_string_literal: true

class Asset < ApplicationRecord
  belongs_to :owner, polymorphic: true
end
