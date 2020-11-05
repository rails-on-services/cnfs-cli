# frozen_string_literal: true

class Manifest
  include ActiveModel::Model
  # include ActiveModel::Validations

  attr_accessor :config_files_paths, :manifests_path, :purged

  def was_purged?
    @purged
  end

  def outdated?
    return false if config_files.empty?

    manifest_files.empty? || (youngest_config_file_updated_at > oldest_manifest_file_generated_at)
  end

  def purge!
    @purged = true
    FileUtils.rm_rf(manifest_files)
  end

  # @return [DateTime]
  def youngest_config_file_updated_at
    find_earliest_latest(config_files, :max)
  end

  def config_files
    Dir[*config_files_paths.map { |path| path.join('**/*.yml') }]
  end

  # @return [DateTime]
  def oldest_manifest_file_generated_at
    find_earliest_latest(manifest_files, :min)
  end

  def manifest_files
    Dir[manifests_path.join('**/*')]
  end

  def find_earliest_latest(list, method)
    list.reject { |f| File.symlink?(f) }.map { |f| File.mtime(f) }.send(method)
  end
end
