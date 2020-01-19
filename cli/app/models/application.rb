# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :deployments
  has_many :targets, through: :deployments

  has_many :application_services
  has_many :services, through: :application_services
  has_many :service_tags, through: :services, source: :tags

  has_many :application_resources
  has_many :resources, through: :application_resources
  has_many :resource_tags, through: :resources, source: :tags

  # NOTE: All application types can have an endpoint
  store :config, accessors: %i[endpoint deploy_tag image_registry], coder: YAML
  # store :config, accessors: %i[path], coder: YAML

  def to_env; Config::Options.new.merge!(environment).to_hash end

  # NOTE: An application consists of multiple services each of which may have their own:
  # - container registry
  # - git repo
  # - image tag calculation/format
  # - version
  # - image prefix
  validates :deploy_tag, presence: true

  # NOTE: These values are used to build, push, pull and deploy images
  # so they need to be available to all controllers
  # TODO: Image stuff should probably move to the service model
  def image_tag(target) end

  # TODO: Bump should probably move to the rails plugin
  # def version; Dir.chdir(Ros.root) { Bump::Bump.current } end
  def version; '0.99' end

  # NOTE: image_prefix is specific to the resource so the default implementation is to return nil
  def image_prefix(target); end

  def git; @git ||= Cnfs.git_details end
end
