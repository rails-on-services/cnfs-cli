# frozen_string_literal: true

class Provider < ApplicationRecord
  include Concerns::Asset
  include Concerns::Extendable
end
