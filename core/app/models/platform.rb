# frozen_string_literal: true

# OS methods
class Platform
  include ActiveModel::Validations

  validate :supported_platform

  def supported_platform
    errors.add(:platform, 'not supported') if os.eql?('unknown')
  end

  def to_hash() = @to_hash ||= JSON.parse(as_hash.to_json)

  def as_hash() = { arch: arch, os: os }.merge(gid)

  def arch
    case config['host_cpu']
    when 'x86_64'
      'amd64'
    else
      config['host_cpu']
    end
  end

  def gid
    ext_info = {}
    if os.eql?('linux') && Etc.getlogin
      shell_info = Etc.getpwnam(Etc.getlogin)
      ext_info[:puid] = shell_info.uid
      ext_info[:pgid] = shell_info.gid
    end
    ext_info
  end

  def os
    case config['host_os']
    when /linux/
      'linux'
    when /darwin/
      'darwin'
    else
      'unknown'
    end
  end

  def config() = @config ||= RbConfig::CONFIG
end
