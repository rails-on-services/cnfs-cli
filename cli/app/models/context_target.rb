# frozen_string_literal: true

class ContextTarget < ApplicationRecord
  belongs_to :context
  belongs_to :target
end
