# frozen_string_literal: true

class ServiceTag < ApplicationRecord
  belongs_to :service
  belongs_to :tag
end

