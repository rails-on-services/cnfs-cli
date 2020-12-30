# frozen_string_literal: true

class Push < ApplicationRecord
  store :config, accessors: %i[manifest box_dir]
  store :aws, accessors: %i[s3_bucket profile region], prefix: true

  parse_sources :project

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.string :name
        t.string :config
        t.string :aws
      end
    end
  end
end
