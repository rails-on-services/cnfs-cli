# frozen_string_literal: true

class ResourceTag < ApplicationRecord
  belongs_to :resource
  belongs_to :tag
end

