# frozen_string_literal: true

class Provisioner::Shell < Provisioner
  store :config, accessors: %i[inline]

  validates :inline, presence: true

  # def set_defaults; end
end
