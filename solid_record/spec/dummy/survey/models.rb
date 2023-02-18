# frozen_string_literal: true

class Survey < ActiveRecord::Base
  include SolidRecord::Model
  def self.table_name_prefix = 'surveys_'
  def self.key_column = 'name'

  has_many :questions
  has_many :answers

  attr_encrypted :hi

  store :defaults, accessors: %i[this that], coder: YAML
  # has_many :hosts

  class << self
    def after_load = puts('after_load')

    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :namo
        t.string :description
        t.string :defaults
        t.string :hi
      end
    end
  end
end

class Question < ActiveRecord::Base
  include SolidRecord::Model
  def self.table_name_prefix = 'surveys_'
  def self.key_column = 'name'

  belongs_to :survey

  class << self
    def after_load = puts('after_load')

    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :survey
        t.string :name
        t.string :description
      end
    end
  end
end

class Answer < ActiveRecord::Base
  include SolidRecord::Model
  def self.table_name_prefix = 'surveys_'
  def self.key_column = 'name'

  belongs_to :survey

  class << self
    def after_load = puts('after_load')

    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :survey
        t.string :name
        t.string :description
      end
    end
  end
end
