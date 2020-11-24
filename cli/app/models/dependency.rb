# frozen_string_literal: true

class Dependency < ApplicationRecord
  include BelongsToProject

  class << self
    def dirs
      [Cnfs.gem_root.join('config').to_s]
    end
  end
end
