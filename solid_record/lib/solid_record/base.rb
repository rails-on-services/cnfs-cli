# frozen_string_literal: true

module SolidRecord
  class Base < ActiveRecord::Base
    self.abstract_class = true
    include SolidRecord::Model
  end
end
