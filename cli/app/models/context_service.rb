# frozen_string_literal: true

class ContextService < ApplicationRecord
  belongs_to :context
  belongs_to :service
end
