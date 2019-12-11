# frozen_string_literal: true

# Application has_many :layers
# Layer has_many :services
# The cluster uat app will have the support layer (pg, redis, etc)
# but the cluster staging and prod will not
# Deployment is a set of targets and an application

class Deployment < ApplicationRecord
  belongs_to :application
  has_many :deployment_targets
  has_many :targets, through: :deployment_targets

  store :config, accessors: %i[base_path image_environment], coder: YAML

  validates :base_path, presence: true
  validates :name, presence: true

  def deploy_path; root.join(base_path) end

  def root; Pathname.new(Dir.pwd) end

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
end
