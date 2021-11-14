# frozen_string_literal: true

class Dependency < ApplicationRecord
  store :config, accessors: %i[linux mac]

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :config
      end
    end

    def after_node_load
      YAML.load_file(file_name).each { |name, values| create(values.merge(name: name)) } if file_name.exist?
    end

    def file_name
      CnfsCli.configuration.paths.config.join("#{table_name}.yml")
    end
  end
end
