# frozen_string_literal: true

class Manifest
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :project, :config_files_paths

  delegate :environment, :write_path, to: :project

  validate :outdated?

  def outdated?
    return if config_files.empty?

    if files.empty?
      errors.add(:missing_manifests, 'No manifest files found')
    else
      config_latest = youngest_config_file_updated_at
      manifest_latest = oldest_manifest_file_generated_at
      errors.add(:stale_manifest, "#{config_latest} > #{manifest_latest}") if config_latest > manifest_latest
    end
    errors.size.positive?
  end

  def generate
    purge! unless valid?
    Cnfs.logger.info 'Generating files'
    environment.runtimes.each do |runtime|
      Cnfs.project.runtime = runtime
      runtime.generate
    end
    files
  end

  def purge!
    @purged = true
    write_path.rmtree
    files
  end

  def purged?
    @purged || false
  end

  def config_files
    Dir[*config_files_paths.map { |path| path.join('**/*.yml') }]
  end

  def files
    write_path.mkpath unless write_path.exist?
    Dir[write_path.join('**/*')]
  end

  private

  # @return [DateTime]
  def youngest_config_file_updated_at
    find_earliest_latest(config_files, :max)
  end

  # @return [DateTime]
  def oldest_manifest_file_generated_at
    find_earliest_latest(files, :min)
  end

  def find_earliest_latest(list, method)
    list.reject { |f| File.symlink?(f) }.map { |f| File.mtime(f) }.send(method)
  end
end
