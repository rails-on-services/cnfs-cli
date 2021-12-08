# frozen_string_literal: true

class Dependency < ApplicationRecord
  include Concerns::Asset
  include Concerns::Download

  store :config, accessors: %i[source linux mac]

  # rubocop:disable Metrics/MethodLength
  # TODO: Refactor this to just run tty-which on self which already has the name
  # so no need to iterate over anything
  # TODO: Make it CnfsCli.config.platform then when it moves to CnfsCore its no biggie
  def set_capabilities
    cmd = TTY::Command.new(printer: :null)
    installed_tools = []
    missing_tools = []
    tools.each do |tool|
      if cmd.run!("which #{tool}").success?
        installed_tools.append(tool)
      else
        missing_tools.append(tool)
      end
    end
    Cnfs.logger.warn "Missing dependency tools: #{missing_tools.join(', ')}" if missing_tools.any?
    installed_tools
  end

  def do_download(version)
    dep = with_other(operator: { 'version' =>  version }, platform: CnfsCli.platform.to_hash)
    url = Pathname.new(dep['config']['source'])
    file = cache_path.join(version, url.basename)
    return if file.exist?

    download(url: url, path: cache_path.join(version))
  end

  def cache_path() = CnfsCli.config.cli_cache_home.join('dependencies', name)
end
