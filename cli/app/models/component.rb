# frozen_string_literal: true

class Component < ApplicationRecord
  belongs_to :owner, class_name: 'Component'
  belongs_to :context
  has_one :parent, as: :owner, class_name: 'Node'

  has_many :components, foreign_key: 'owner_id'

  # Pluralized resource names are declared as a has_many
  Cnfs.config.asset_names.select{ |name| name.pluralize.eql?(name) }.each do |asset_name|
    has_many asset_name.to_sym, as: :owner
  end

  store :config, coder: YAML

  validates :name, presence: true

  # updates this component's context and it's owner's context (recursive until owner is nil)
  def update_context(context:)
    update(context: context)
    owner&.update_context(context: context)
  end

  def runtime
    resource&.runtime
  end

  # Scan all resources for a runtime association
  # If none is found then recursively call the owning component looking for a runtime
  # If none or multiple runtimes are found log a warning and return nil
  def resource
    runtime_resources = resources.select(&:runtime)
    size = runtime_resources.size
    if size.zero?
      Cnfs.logger.warn('No defined runtimes') if owner.nil?
      owner&.resource
    elsif size.eql?(1)
      runtime_resources.first
    else
      Cnfs.logger.warn("Multiple defined runtimes found in: #{runtime_resources.map(&:name).join(' ')}")
    end
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :owner
        t.references :context
        t.string :name
        t.string :config
        t.string :type
      end
    end
  end
end
