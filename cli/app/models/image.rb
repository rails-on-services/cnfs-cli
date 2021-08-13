# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :repository

  def as_save
    attributes.except('id', 'name')
  end

  def generate
    Rails::ServiceGenerator.new([self])
  end

  class << self
    def create_table(schema)
      schema.create_table :images, force: true do |t|
        # t.references :owner, polymorphic: true
        t.references :repository
        t.string :_source
        t.string :config
        t.string :dockerfile
        t.string :build
        t.string :name
        # t.string :path
        t.string :type
        t.string :tags
      end
    end
  end
end
