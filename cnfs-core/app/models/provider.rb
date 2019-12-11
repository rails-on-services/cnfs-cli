# frozen_string_literal: true

class Provider < ApplicationRecord
  store :config, accessors: %i[credentials storage mq], coder: YAML
  # def kubernetes; options_hash(:kubernetes) end
end
