# frozen_string_literal: true

class ApplicationService < ApplicationRecord
  belongs_to :application
  belongs_to :service
end
