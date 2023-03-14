# frozen_string_literal: true

module SolidRecord
  def self.infra = Infra
end

module Infra
  class << self
    def g = @g ||= Group.last
    def h = @h ||= Host.last
    def s = @s ||= Service.last

    def su = s.update(port: (s.port || 0) + 1)
    def hu = h.update(port: (h.port || 0) + 1)

    def plural_hash
      require_relative 'models'
      SolidRecord.setup
      SolidRecord.toggle_callbacks do
        SolidRecord::File.create(source: 'infra/plural_hash/groups.yml', namespace: 'infra')
      end
    end
  end
end
