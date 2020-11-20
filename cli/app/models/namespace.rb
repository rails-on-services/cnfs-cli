# frozen_string_literal: true

class Namespace < ApplicationRecord
  belongs_to :key
  belongs_to :environment
  has_many :services

  validates :name, presence: true

  delegate :encrypt, :decrypt, to: :key

  store :config, accessors: %i[main], coder: YAML

  class << self
    def parse
      output = environments.each_with_object({}) do |e, hash|
        next unless e.join('namespaces.yml').exist?

        begin
          env = e.split.last.to_s
          content = File.read(e.join('namespaces.yml'))
          yaml = YAML.load(content)
          yaml.each_with_object(hash) do |(k, v), h|
            h["#{env}_#{k}"] = v.merge(name: k, environment: env)
          end
        rescue => e
          Cnfs.logger.info e.message
        end
      end
      write_fixture(output)
    end
  end
end
