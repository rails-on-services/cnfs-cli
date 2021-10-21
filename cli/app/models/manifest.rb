# frozen_string_literal: true

class Manifest
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :config_files_paths, :write_path

  validate :outdated?

  def outdated?
    return if config_files.empty?

    if manifest_files.empty?
      errors.add(:missing_manifests, 'No manifest files found')
    else
      config_latest = youngest_config_file_updated_at
      manifest_latest = oldest_manifest_file_generated_at
      errors.add(:stale_manifest, "#{config_latest} > #{manifest_latest}") if config_latest > manifest_latest
    end
    Cnfs.logger.info("manifest validated - OK") unless errors.size.positive?
    errors.size.positive?
  end

  def purge!
    @purged = true
    write_path.rmtree
    manifest_files
  end

  def purged?
    @purged || false
  end

  def config_files
    Dir[*config_files_paths.map { |path| path.join('**/*.yml') }]
  end

  def manifest_files
    write_path.mkpath unless write_path.exist?
    Dir[write_path.join('**/*')]
  end

  private

  # @return [DateTime]
  def youngest_config_file_updated_at
    file_mtimes(config_files).max
  end

  # @return [DateTime]
  def oldest_manifest_file_generated_at
    file_mtimes(manifest_files).min
  end

  def file_mtimes(list)
    list.reject { |f| File.symlink?(f) }.map { |f| File.mtime(f) }
  end
end
