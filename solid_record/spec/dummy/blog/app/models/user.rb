# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class User < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'first'

  has_many :blogs, foreign_key: 'kid'
  has_many :posts, through: :blogs

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :first
        t.string :last
      end
    end
  end
end

class Blog < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'name'

  belongs_to :user, foreign_key: 'kid'

  has_many :posts

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        # t.references :user, solid: true
        t.integer :kid
        t.string :user_name
        t.string :name
      end
    end
  end
end

class Post < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'title'

  belongs_to :blog

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :blog, solid: true
        t.string :title
        t.text :content
      end
    end
  end
end
