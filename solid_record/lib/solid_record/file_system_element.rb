# frozen_string_literal: true

module SolidRecord
  module FileSystemElement
    extend ActiveSupport::Concern

    included do
      store :config, accessors: %i[path]
      validates :path, presence: true
      validate :path_exists, if: -> { path }
    end

    def path_exists() = pathname.exist?

    def pathname() = @pathname ||= Pathname.new(path)
  end
end
