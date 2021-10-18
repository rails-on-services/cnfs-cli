# frozen_string_literal: true

class Target < ApplicationRecord
  include Concerns::Component
  # include Concerns::HasEnvs

  class << self
    def add_columns(t)
      # t.string :runtime_name
    end
  end
end
