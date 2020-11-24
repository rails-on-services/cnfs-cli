# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  store :tags, coder: YAML
  store :environment, coder: YAML

  # NOTE: Baes implementation; Override for custom parsing
  class << self
    def parse
      begin
        output = dirs.each_with_object({}) do |dir, output|
          file = "#{dir}/#{table_name}.yml"
          next unless File.exist?(file)

          yaml = YAML.load_file(file)
          yaml.each_with_object(output) do |(k, v), h|
            h[k] = v.merge(name: k, project: 'app')
            yield h[k] if block_given?
          end
        end
        write_fixture(output)
      rescue => e
        binding.pry if Cnfs.cli_mode.development?
      end
    end

    def dirs
      ['config']
    end

    def write_fixture(content)
      Cnfs.logger.debug "parsing #{content}"
      Cnfs.logger.info "parsing #{table_name}"
      File.open(Cnfs::Configuration.dir.join("#{table_name}.yml"), 'w') do |file|
        file.write(content.deep_stringify_keys.to_yaml)
      end
    end

    def environments
      Cnfs.paths.config.join('environments').children.select(&:directory?)
    end
  end

  # Provides a default empty hash to validate against
  # Override in model to validate against a specific schema
  # def self.schema
  #   {}
  # end

  # pass in a schema or uses the class default schema
  # usage: validator.valid?(payload hash)
  # See: https://github.com/davishmcclurg/json_schemer
  # def validator(schema = self.class.schema)
  #   JSONSchemer.schema(schema)
  # end

  # env_scope is ignored; implemented to maintain compatibility with service model
  def to_env(env = nil, _env_scope = nil)
    all = environment.dig(:all) || {}
    env = (environment.dig(env) || {}).merge(all)
    env.empty? ? nil : Config::Options.new.merge!(env)
  end
end
