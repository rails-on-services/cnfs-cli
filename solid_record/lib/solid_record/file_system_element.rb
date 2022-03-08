# frozen_string_literal: true

module SolidRecord
  module FileSystemElement
    extend ActiveSupport::Concern

    included do
      store :config, accessors: %i[path]
      delegate :name, to: :pathname
      validate :path_exists

      delegate :write, to: :parent, prefix: true, allow_nil: true
      after_commit :parent_write, on: :destroy, if: -> { parent&.type&.eql?('SolidRecord::Path') }
    end

    def path_exists
      errors.add("invalid path #{path}") unless pathname.exist?
    end

    def pathname() = @pathname ||= Pathname.new(path || '')
  end
end
