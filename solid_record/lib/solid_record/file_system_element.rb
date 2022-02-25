# frozen_string_literal: true

module SolidRecord
  module FileSystemElement
    extend ActiveSupport::Concern

    included do
      store :config, accessors: %i[path]
      delegate :exist?, to: :pathname
      # validates :path, presence: true
      validate :path_exists

      delegate :write, to: :parent, prefix: true
      after_commit :parent_write, on: :destroy, allow_nil: true
    end

    def path_exists
      errors.add("invalid path #{path}") unless exist?
    end

    def pathname() = @pathname ||= Pathname.new(path || '')

    def tree_label() = "#{pathname.name} (#{self.class.to_s.demodulize})"
  end
end
