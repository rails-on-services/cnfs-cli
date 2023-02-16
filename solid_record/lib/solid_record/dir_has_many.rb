# frozen_string_literal: true

module SolidRecord
  class DirHasMany < Dir
    def process_contents # rubocop:disable Metrics/AbcSize
      pathname.children.select(&:file?).each do |path|
        segments << File.create(parent: self, root: root, path: path.to_s, model_class_name: model_class_name,
                                owner: owner, content_format: :singular)
      end

      pathname.children.select(&:directory?).each do |path|
        SolidRecord.raise_or_warn(StandardError.new("#{invalid_path(path)} has_many dir is not allowed"))
      end
    end
  end
end
