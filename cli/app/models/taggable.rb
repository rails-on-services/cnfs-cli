# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  class_methods do
    def by_tags(tags = project.tags)
      where("tags LIKE ?", tags.map { |k, v| "%#{k}: #{v}%" }.join)
    end

    # TODO: Maybe move to ApplicationRecord
    def project
      Cnfs.project
    end
  end
end
