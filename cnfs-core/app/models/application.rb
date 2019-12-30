# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :application_services
  has_many :services, through: :application_services
  has_many :service_tags, through: :services, source: :tags

  has_many :application_resources
  has_many :resources, through: :application_resources
  has_many :resource_tags, through: :resources, source: :tags

  store :config, accessors: %i[path], coder: YAML

  # NOTE: If these methods can be used across application types then they should be here
  # otherwise they should be in the model for the specific application type
  def registry_secret_name; "registry-#{config.image_registry}" end

  def image_tag; [version, image_prefix, git.sha].compact.join('-') end

  # def version; Dir.chdir(Ros.root) { Bump::Bump.current } end
  def version; '0.99' end

  # NOTE: image_prefix is specific to the resource so the default implementation is to return nil
  def image_prefix; end

  def git; @git ||= git_details end

  def git_details
    Dir.chdir(path) do
      return Config::Options.new unless system('git rev-parse --git-dir > /dev/null 2>&1')

      Config::Options.new(
        tag_name: %x(git tag --points-at HEAD).chomp,
        branch_name: %x(git rev-parse --abbrev-ref HEAD).strip.gsub(/[^A-Za-z0-9-]/, '-'),
        sha: %x(git rev-parse --short HEAD).chomp
      )
    end
  end

  def root
    @root ||= (cwd = Dir.pwd
      while not cwd.eql?('/')
        break Pathname.new(cwd) if File.exist?("#{cwd}/config/cnfs.yml")
        cwd = File.expand_path('..', cwd)
      end)
  end
end
