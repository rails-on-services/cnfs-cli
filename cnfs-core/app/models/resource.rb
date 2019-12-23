# frozen_string_literal: true

class Resource < ApplicationRecord
  belongs_to :layer

  store :config, accessors: %i[tf_version], coder: YAML
end
