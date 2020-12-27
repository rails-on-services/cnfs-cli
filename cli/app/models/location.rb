# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :resources
  has_many :services

  # disable save to YAML
  def save_in_file; end

  class << self
    # records are created 'on demand' so disable parsing of a config file
    def parse; end

    def after_parse
      location_names = %w[resources services].each_with_object([]) do |item, ary|
        yaml = YAML.load_file(Cnfs::Configuration.dir.join("#{item}.yml"))
        locations = yaml.each_value.map { |m| m['location'] }.compact
        ary.concat(locations)
      end
      location_names.uniq.each do |location_name|
        id = ActiveRecord::FixtureSet.identify(location_name)
        Location.create(id: id)
      end
    end

    def create_table(schema)
      schema.create_table :locations, force: true
    end
  end
end
