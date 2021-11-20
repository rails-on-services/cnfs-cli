# frozen_string_literal: true

class Builder < ApplicationRecord
  include Concerns::Asset
  include Concerns::Operator
end
