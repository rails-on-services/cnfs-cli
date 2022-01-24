# frozen_string_literal: true

class Hendrix::ApplicationRecord < ActiveRecord::Base
  # include SolidRecord::Table

  self.abstract_class = true
end
