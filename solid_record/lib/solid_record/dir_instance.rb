# frozen_string_literal: true

module SolidRecord
  class DirInstance < Dir
    def process_contents
      pathname.glob(glob).each do |path|
        c_hash = create_hash.merge(path: path.to_s, model_class_name: model_class_name, content_format: :singular)
        # binding.pry
        segments << File.create(c_hash)
      end

      # TODO: Implement
      # pathname.children.select(&:directory?).each do |path|
      # end
    end
  end
end
