# frozen_string_literal: true

class Registry < ApplicationRecord
  include Concerns::Asset
  include Concerns::Extendable
end
