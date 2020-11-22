# frozen_string_literal: true

class User < ApplicationRecord
  include BelongsToProject
  include Taggable
end
