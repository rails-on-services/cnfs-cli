# frozen_string_literal: true

module SolidRecord
  class DirInstance < Dir
    def process_contents
      self.model_class_name ||= pathname.name.classify
      # binding.pry
      pathname.glob(glob).each do |path|
        create_segment(File, path: path.to_s, model_class_name: model_class_name, content_format: :singular)
      end

      # TODO: Implement
      # children.select(&:directory?).each do |path|
      # end
    end
  end
end
