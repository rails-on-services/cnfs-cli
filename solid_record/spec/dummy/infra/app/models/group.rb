# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.inheritance_column = 'kind'
end

# binding.pry
class Group < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'name'

  attr_encrypted :hi

  store :defaults, accessors: %i[host_version], coder: YAML

  has_many :hosts

  class << self
    def after_load() = puts('after_load')

    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :hi
        t.string :auth_domain
        t.string :network
        t.string :domain
        t.string :defaults
      end
    end
  end
end

class Host < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'host'

  belongs_to :group

  serialize :shares, Array
  # serialize :services, Array
  has_many :services

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        # t.solid
        t.references :group # , solid: true
        t.string :host
        t.string :kind
        t.string :ip
        t.integer :port
        t.string :vpn_type
        t.string :version
        t.string :shares
        t.string :services
      end
    end
  end
end

class Vpn < Host
  def connect() = puts('connect')
  # after_create :bind_it

  def bind_it
    puts 'bind it'
    # binding.pry
  end
end

class Dc < Host; end

class AFile < Host; end

class Hv < Host; end

class Imm < Host; end

class Firewall < Host; end

class Service < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'name'

  belongs_to :host

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.references :host
        t.string :port
      end
    end
  end
end

class Repo < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'local'

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        # t.solid
        t.string :local
        t.string :remote
      end
    end
  end
end

class Home < ApplicationRecord
  include SolidRecord::Model
  def self.key_column() = 'string'

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        # t.solid
        t.string :string
      end
    end
  end
end
