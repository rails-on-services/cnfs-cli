# frozen_string_literal: true

class ApplicationResource < ApplicationRecord
  belongs_to :application
  belongs_to :resource
end

