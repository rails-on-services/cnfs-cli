# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
	self.abstract_class = true
end

class User < ApplicationRecord
	include SolidRecord::Model

	has_many :blogs

	class << self
		def create_table(schema)
			schema.create_table table_name, force: true do |t|
        t.solid
				t.string :first
				t.string :last
			end
		end
	end
end

class Blog < ApplicationRecord
	include SolidRecord::Model

	belongs_to :user

	has_many :posts

	class << self
		def create_table(schema)
			schema.create_table table_name, force: true do |t|
        t.solid
				t.references :user, solid: true
				t.string :name
			end
		end
	end
end

class Post < ApplicationRecord
	include SolidRecord::Model

	belongs_to :blog

	class << self
		def create_table(schema)
			schema.create_table table_name, force: true do |t|
        t.solid
				t.references :blog, solid: true
				t.string :title
				t.text :content
			end
		end
	end
end
