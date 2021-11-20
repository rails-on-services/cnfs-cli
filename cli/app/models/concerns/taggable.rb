# frozen_string_literal: true

module Concerns
  module Taggable
    extend ActiveSupport::Concern

    included do
      table_mod :tags_add_column

      store :tags, coder: YAML
    end

    class_methods do
      def tags_add_column(t)
        t.string :tags
      end

      def by_tags(tags = project.tags)
        where('tags LIKE ?', tags.map { |k, v| "%#{k}: #{v}%" }.join)
      end
    end
  end
end
