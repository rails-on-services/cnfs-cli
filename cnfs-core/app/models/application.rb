# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :application_services
  has_many :services, through: :application_services
  has_many :application_resources
  has_many :resources, through: :application_resources

=begin
  def registry_secret_name; "registry-#{config.image_registry}" end

  # NOTE: This is the default implementation; Can be overridden by a Partition, Component or Resource
  def image_tag; [version, image_prefix, git.sha].compact.join('-') end

  # def version; Dir.chdir(Ros.root) { Bump::Bump.current } end
  def version; '0.99' end

  # NOTE: image_prefix is specific to the resource so the default implementation is to return nil
  def image_prefix; end

  def git; @git ||= git_details end

  def git_details
    return Config::Options.new unless system('git rev-parse --git-dir > /dev/null 2>&1')
    Config::Options.new(
      tag_name: %x(git tag --points-at HEAD).chomp,
      branch_name: %x(git rev-parse --abbrev-ref HEAD).strip.gsub(/[^A-Za-z0-9-]/, '-'),
      sha: %x(git rev-parse --short HEAD).chomp
    )
  end

  def root
    @root ||= (cwd = Dir.pwd
      while not cwd.eql?('/')
        break Pathname.new(cwd) if File.exist?("#{cwd}/config/cnfs.yml")
        cwd = File.expand_path('..', cwd)
      end)
  end

  def cnfs_services_root; is_cnfs? ? root : root.join('ros') end

  def has_cnfs?; not is_cnfs? and Dir.exists?(cnfs_services_root) end

  # TODO: This is a hack in order to differentiate for purpose of templating files
  def is_cnfs?
    platform_name.eql?('cnfs')
  end
  # def is_cnfs?
  #   config.image_registry.eql?('railsonservices') and config.partition_name.eql?('cnfs')
  # end
=end

  store :config, accessors: %i[secret_key_base rails_master_key jwt_encryption_key], coder: YAML

  def partition_name # called by CredentialsController
    environment.self.platform.partition_name
  end

  # Called by RuntimeGenerator
  def to_env(target)
    env = environment.self.merge!(platform: { jwt: jwt(target) }).merge!(other_stuff)
    env.merge!(target.provider.credentials) if target.provider.credentials
    env
  end

  def jwt(target)
    jwt = {
      aud: "https://api.#{target.domain_name}",
      iss: "https://iam.api.#{target.domain_name}"
    }
    jwt.merge!(environment.dig(:self, :platform, :jwt) || {})
    jwt.merge!(encryption_key: Cnfs::Core.decrypt(jwt_encryption_key))
  end

  def other_stuff
    {
      bucket_endpoint_url: 'http://localstack:4572',
      infra: { provider: 'aws' },
      platform: {
        api_docs: {
          server: { host: "https://api.development.demo.cnfs.io" }
        },
        postman: { workspace: 'api.development.demo.cnfs.io' },
        connection: { type: 'host' },
				external_connection_type: 'path',
				feature_set: 'mounted',
				hosts: 'api.development.demo.cnfs.io'
      }
    }
  end
end
