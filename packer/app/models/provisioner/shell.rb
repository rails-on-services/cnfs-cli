# frozen_string_literal: true

class Provisioner::Shell < Provisioner
  store :config, coder: YAML, accessors: %i[inline]
end
