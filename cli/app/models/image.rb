# frozen_string_literal: true

class Image < ApplicationRecord
  include Concerns::Asset

  # belongs_to :repository

  # def generate
  #   Rails::ServiceGenerator.new([self])
  # end

  class << self
    def add_columns(t)
      t.references :repository
      t.string :dockerfile
      t.string :build
      # t.string :path
    end
  end
end
