# frozen_string_literal: true

module Concerns
  module Taggable
    extend ActiveSupport::Concern

    included do
      store :tags, coder: YAML
    end

    class_methods do
      def add_columns(t)
        t.string :tags
        super
      end

      def by_tags(tags = project.tags)
        where('tags LIKE ?', tags.map { |k, v| "%#{k}: #{v}%" }.join)
      end
    end
  end
end
