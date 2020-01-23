# frozen_string_literal: true

class Service < ApplicationRecord
  # NOTE: The class_name is the STI super class rather than sub-class so that any subclass could work
  # meaning that a source_repo could be class Repository::Git or Repository::Svn, etc in future
  belongs_to :source_repo, class_name: 'Repository'
  belongs_to :image_repo, class_name: 'Repository'
  belongs_to :chart_repo, class_name: 'Repository'

  has_many :service_tags
  has_many :tags, through: :service_tags

  # def runtime_repositories
  #   [image_repo, chart_repo].compact
  # end

  store :config, accessors: %i[path], coder: YAML

  def test_commands(_options = nil)
    []
  end

  # Called by RuntimeGenerator#service_environment
  def to_env(target = nil)
    @target = target
    env = Config::Options.new.merge!(environment)
    if (deployment_env = target.deployment.service_environments[name])
      env.merge!(Config::Options.new.merge!(deployment_env).to_hash)
    end
    env.empty? ? nil : env
  end
end
