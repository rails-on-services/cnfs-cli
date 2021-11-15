# frozen_string_literal: true

class Component < ApplicationRecord
  include Concerns::Parent
  include Concerns::Encryption
  include Concerns::Interpolation

  belongs_to :owner, class_name: 'Component'
  has_one :parent, as: :owner, class_name: 'Node'
  has_one :context

  has_many :components, foreign_key: 'owner_id'

  has_many :context_components
  has_many :contexts, through: :context_components

  # Pluralized resource names are declared as a has_many
  CnfsCli.asset_names.select { |name| name.pluralize.eql?(name) }.each do |asset_name|
    has_many asset_name.to_sym, as: :owner
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :owner
        t.string :name
        t.string :config
        t.string :sub_config
        t.string :type
        t.string :segment
        t.string :default
      end
    end
  end
end
