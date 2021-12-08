# frozen_string_literal: true

class Dependency < ApplicationRecord
  include Concerns::Asset
  include Concerns::Download

  store :config, accessors: %i[source linux mac]

  validate :available

  # TODO: Search cache path instead of system directories or an option to do so
  # TTY::Which.which("ruby", paths: ["/usr/local/bin", "/usr/bin", "/bin"])
  def available
    errors.add(:dependency_not_found, name) unless TTY::Which.exist?(name)
  end

  def do_download(version)
    dep = with_other(operator: { 'version' => version }, platform: CnfsCli.platform.to_hash)
    url = Pathname.new(dep['config']['source'])
    file = cache_path.join(version, url.basename)
    return if file.exist?

    download(url: url, path: cache_path.join(version))
  end

  def cache_path() = CnfsCli.config.cli_cache_home.join('dependencies', name)
end
