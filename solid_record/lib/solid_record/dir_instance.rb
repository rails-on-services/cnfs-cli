# frozen_string_literal: true

module SolidRecord
  class DirInstance < Dir
    def process_contents
      pathname.glob(glob).each do |path|
        segments << FileOne.create(parent: self, path: path.to_s, model_class_name: model_class_name)
      end

      # TODO: Implement
      pathname.children.select(&:directory?).each do |path|
      end
    end
  end
end
