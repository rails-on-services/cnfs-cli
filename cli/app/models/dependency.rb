# frozen_string_literal: true

class Dependency < ApplicationRecord
  include Concerns::Asset

  store :config, accessors: %i[linux mac]
end
