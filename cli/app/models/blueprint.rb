# frozen_string_literal: true

class Blueprint < ApplicationRecord
  belongs_to :environment

  class << self
    def parse
      output = environments.each_with_object({}) do |e, h|
        env = e.split.last.to_s
        env_file = "config/environments/#{env}/blueprints.yml"
        yaml = File.exist?(env_file) ? YAML.load_file(env_file) : {}
        yaml.each do |key, value|
          h["#{env}_#{key}"] = value.merge(name: env, environment: env)
        end
      end
      write_fixture(output)
    end
  end
end
