# frozen_string_literal: true

class Manifest
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations

  attr_accessor :source_paths, :source_glob, :destination_path, :destination_glob

  validate :outdated, :no_destination_files

  def initialize(**options)
    assign_attributes(**options)
    @source_glob ||= '**/*.yml'
    @destination_path ||= '.'
    @destination_glob ||= '**/*'
  end

  def reload
    @source_files, @destination_files, @newest_source, @oldest_destination = nil
    self.validate
    self
  end

  def source_files() = @source_files ||= read_paths.map { |path| path.glob(source_glob) }.flatten

  def destination_files() = @destination_files ||= write_path.glob(destination_glob)

  private

  def outdated
    return if source_files.empty? || destination_files.empty? || oldest_destination > newest_source

    errors.add(:stale_files, "#{newest_source} > #{oldest_destination}")
  end

  def no_destination_files
    errors.add(:no_files_found, write_path.to_s) if source_files.any? && destination_files.empty?
  end

  def read_paths() = [source_paths].flatten.compact.map{ |p| Pathname.new(p) }

  def write_path() = Pathname.new(destination_path)

  # @return [DateTime]
  def newest_source() = @newest_source ||= file_mtimes(source_files).max

  # @return [DateTime]
  def oldest_destination() = @oldest_destination ||= file_mtimes(destination_files).min

  def file_mtimes(list) = list.reject { |f| File.symlink?(f) }.map { |f| File.mtime(f) }
end
