# frozen_string_literal: true

class Dependency < ApplicationRecord
  include Concerns::Download
  include Concerns::Generic

  store :config, accessors: %i[source linux mac]

  validate :available

  # TODO: Search cache path instead of system directories or an option to do so
  # TTY::Which.which("ruby", paths: ["/usr/local/bin", "/usr/bin", "/bin"])
  def available
    return unless Node.source.eql?(:asset)

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

  # This may be about TF modules rather than binaries like tf, kubectl, etc
  # TODO: Figure out how to manage these
  # def dependencies
  #   super.map(&:with_indifferent_access)
  # end

  # TODO: What is this for?
  # def fetch_data_repo
  #   Cnfs.logger.info "Fetching data source v#{data.config.data_version}..."
  #   File.open('data.tar.gz', 'wb') do |fo|
  #     fo.write open("https://github.com/#{data.config.data_repo}/archive/#{data.config.data_version}.tar.gz",
  #                   'Authorization' => "token #{data.config.github_token}",
  #                   'Accept' => 'application/vnd.github.v4.raw').read
  #   end
  #   `tar xzf "data.tar.gz"`
  # end
end
