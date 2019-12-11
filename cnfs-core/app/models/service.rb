# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :layer

  def test_commands(options = nil); [] end
end
