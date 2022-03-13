# frozen_string_literal: true

module OneStack
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
