# frozen_string_literal: true

class Namespace < ApplicationRecord
  belongs_to :key
  belongs_to :environment
  has_many :services

  validates :name, presence: true

  delegate :encrypt, :decrypt, to: :key
  delegate :app, :runtime, to: :environment

  store :config, accessors: %i[main], coder: YAML

  class << self
    def parse
      output = environments.each_with_object({}) do |env_path, hash|
        env = env_path.split.last.to_s
        env_path.children.select(&:directory?).each do |ns_path|
          ns = ns_path.split.last.to_s
          file_name = env_path.join("#{ns}.yml")
          base_hash = { name: ns, environment: env }
          if file_name.exist?
            content = File.read(file_name)
            hash["#{env}_#{ns}"] = YAML.load(content).merge(base_hash)
          else
            hash["#{env}_#{ns}"] = base_hash
          end
            # yaml.each_with_object(hash) do |(k, v), h|
            #   h["#{env}_#{ns}"] = v.merge(name: ns, environment: env)
            # end
        # rescue => e
        #   Cnfs.logger.info e.message
        end
      end
      write_fixture(output)
    end
  end
end
