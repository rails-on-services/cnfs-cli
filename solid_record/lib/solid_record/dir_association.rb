# frozen_string_literal: true

module SolidRecord
  class DirAssociation < Dir
    validates :owner, presence: true
    validates :model, presence: false

    def process_contents
      process_has_many_files
      process_belongs_to_files
      process_has_many_dirs
      process_belongs_to_dirs
    end

    def process_has_many_files # e.g. favorites/questions.yml # rubocop:disable Metrics/AbcSize
      pathname.glob(glob).select(&:plural?).each do |path|
        if owner_assn(:has_many).include?(path.name)
          segments << File.create(parent: self, root: root, path: path.to_s, model_class_name: path.name, owner: owner,
                                  content_format: :plural)
        else
          SolidRecord.raise_or_warn(StandardError.new("#{invalid_path(path)} #{msg(:has_many)}"))
        end
      end
    end

    def process_belongs_to_files
      pathname.glob(glob).select(&:singular?).each do |path|
        # TODO: check if the path.name exists as a has_one on the owner
        # TODO: If not then raise an error
      end
    end

    def process_has_many_dirs # rubocop:disable Metrics/AbcSize
      pathname.children.select(&:directory?).select(&:plural?).each do |path|
        if owner_assn(:has_many).include?(path.name)
          segments << DirHasMany.create(parent: self, root: root, path: path.to_s, content_type: :has_many,
                                        model_class_name: path.name, owner: owner)
        else
          SolidRecord.raise_or_warn(StandardError.new("#{invalid_path(path)} #{msg(:has_many)}"))
        end
      end
    end

    def process_belongs_to_dirs
      pathname.children.select(&:directory?).select(&:singular?).each do |path|
        SolidRecord.raise_or_warn(StandardError.new("#{invalid_path(path)} belongs_to dir is not allowed"))
      end
    end
  end
end
