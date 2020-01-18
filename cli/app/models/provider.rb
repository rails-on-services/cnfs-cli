# frozen_string_literal: true

class Provider < ApplicationRecord
  has_many :targets

  store :config, accessors: %i[tf_version], coder: YAML
end
