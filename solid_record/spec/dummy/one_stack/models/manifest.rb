# frozen_string_literal: true

module OneStack
  class Manifest
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations

    # relative_from: Hendrix.config.root
    # attr: Any attribute of Pathname, e.g. :atime, :size
    # Example: Node.list(relative_path_from: Hendrix.config.root).max
    # returns an Array containing one element of the most recently updated Node with its mtime and relative path
    attr_accessor :source, :target, :relative_path_from, :attr

    validate :outdated, :no_target_files

    def initialize(**options)
      assign_attributes(**options)
      @attr ||= :mtime
    end

    def reload
      @source_files, @target_files, @newest_source, @oldest_target = nil
      validate
      self
    end

    def newest_source() = @newest_source ||= list(source_files).max

    def source_files() = @source_files ||= source.call

    def oldest_target() = @oldest_target ||= list(target_files).min

    def target_files() = @target_files ||= target.call

    def rm_targets() = target_files.each { |path| path.delete }

    def list(file_set)
      file_set.select(&:file?).reject(&:symlink?).map do |path|
        path = path.relative_path_from(relative_path_from) if relative_path_from
        [path.send(attr), path]
      end
    end

    private

    def outdated
      return if source_files.empty? || target_files.empty? || oldest_target.first > newest_source.first

      errors.add(:stale_files, "#{newest_source} > #{oldest_target}")
    end

    def no_target_files
      errors.add(:no_files_found, '') if source_files.any? && target_files.empty?
    end
  end
end
