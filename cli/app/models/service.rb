# frozen_string_literal: true

class Service < ApplicationRecord
  attr_accessor :application
  # NOTE: The class_name is the STI super class rather than sub-class so that any subclass could work
  # meaning that a source_repo could be class Repository::Git or Repository::Svn, etc in future
  belongs_to :source_repo, class_name: 'Repository'
  belongs_to :image_repo, class_name: 'Repository'
  belongs_to :chart_repo, class_name: 'Repository'

  # has_many :service_tags
  # has_many :tags, through: :service_tags

  # def runtime_repositories
  #   [image_repo, chart_repo].compact
  # end

  store :config, accessors: %i[path image depends_on ports mount], coder: YAML
  store :config, accessors: %i[shell_command], coder: YAML

  # depends_on is used by compose to set order of container starts
  # shell_command: the command ShellController passes to runtime.exec
  after_initialize do
    self.depends_on ||= []
    self.shell_command ||= :bash
  end

  def test_commands(_options = nil)
    []
  end
end
