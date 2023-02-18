# frozen_string_literal: true

module Blogger
  class << self
    def b = @b ||= Blog.last
    def p = @p ||= Post.last
    def u = @u ||= User.last

    def dir_instance
      require_relative 'models'
      SolidRecord.setup
      SolidRecord.toggle_callbacks do
        SolidRecord::DirInstance.create(source: 'blog/dir_instance', model_class_name: :user, namespace: :blogger)
      end
    end

    def dir_generic
      require_relative 'models'
      SolidRecord.setup
      SolidRecord.toggle_callbacks { SolidRecord::DirGeneric.create(source: 'blog/dir_generic', namespace: :blogger) }
    end
  end
end

module SolidRecord
  class << self
    def b = Blogger
  end
end
