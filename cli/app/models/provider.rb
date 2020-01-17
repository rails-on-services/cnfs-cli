# frozen_string_literal: true

class Provider < ApplicationRecord
  has_many :targets

  store :config, accessors: %i[storage mq tf_version], coder: YAML

  def clients
    { mq: mq, storage: storage }
  end
end
