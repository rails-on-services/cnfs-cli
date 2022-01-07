# frozen_string_literal: true

class User < ApplicationRecord
  include Concerns::Generic

  class << self
    def add_columns(t)
      t.string :role
      t.string :full_name
    end
  end
end
