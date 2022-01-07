# frozen_string_literal: true

class Playbook < ApplicationRecord
  include Concerns::Target

  class << self
    def add_columns(t)
      t.string :configurator_name
      t.references :configurator
    end
  end
end
