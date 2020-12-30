# frozen_string_literal: true

class Project < ApplicationRecord
  PARSE_NAME = 'project'

  has_many :builds

  store :paths, coder: YAML
  store :options, coder: YAML

  def available_packages
    Cnfs.user_data_root.join('packages').children.select(&:directory?)
  end

  def packages_path
    Cnfs.user_data_root.join('packages')
  end

  def paths
    @paths ||= super&.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
  end

  def as_save
    attributes.except('id')
  end

  class << self
    def parse
      content = Cnfs.config.to_hash.slice(
        *reflect_on_all_associations(:belongs_to).map(&:name).append(:name, :paths, :tags)
      )
      # namespace = "#{content[:environment]}_#{content[:namespace]}"
      options = Cnfs.config.delete_field(:options).to_hash if Cnfs.config.options
      output = { PARSE_NAME => content.merge(options: options) }
      create_all(output)
    end

    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :config
        t.string :options
        t.string :paths
        t.string :tags
      end
    end
  end
end
