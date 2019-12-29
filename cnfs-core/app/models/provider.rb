# frozen_string_literal: true

class Provider < ApplicationRecord
  store :config, accessors: %i[storage mq tf_version], coder: YAML

  def resources
    { mq: mq, storage: storage }
  end
end
