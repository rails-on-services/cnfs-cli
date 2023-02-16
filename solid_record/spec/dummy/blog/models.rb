# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class User < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'first'

  has_many :blogs
  has_many :posts, through: :blogs
  has_many :comments

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

  belongs_to :user

  has_many :posts
  has_many :comments, through: :posts

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :user
        t.string :name
      end
    end
  end
end

class Post < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'title'

  belongs_to :blog

  has_many :comments

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :blog
        t.string :title
        t.text :content
      end
    end
  end
end

class Comment < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'title'

  belongs_to :post
  belongs_to :user

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :post
        t.references :user
        t.string :title
        t.text :content
      end
    end
  end
end
