# frozen_string_literal: true

module SolidRecord
  class DirHasMany < Dir
    def process_contents
      pathname.children.select(&:file?).each do |path|
        segments << FileOne.create(parent: self, path: path.to_s, model_class_name: model_class_name, owner: owner)
      end

      pathname.children.select(&:directory?).each do |path|
        SolidRecord.raise_or_warn(StandardError.new("#{invalid_path(path)} has_many dir is not allowed"))
      end
    end
  end
end
