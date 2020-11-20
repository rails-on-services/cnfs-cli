# frozen_string_literal: true

class App < ApplicationRecord
  attr_accessor :options

  belongs_to :environment
  belongs_to :namespace
  belongs_to :repository
  belongs_to :source_repository, class_name: 'Repository'

  has_many :providers
  has_many :runtimes
  has_many :repositories
  has_many :environments
  has_many :namespaces, through: :environments

  store :paths, coder: YAML

  after_initialize do
    self.options ||= Thor::CoreExt::HashWithIndifferentAccess.new
  end

  # If options were passed in then ensure the values are valid (names found in the config)
  validates :environment, presence: { message: 'not found' }, if: -> { options.environment }
  validates :namespace, presence: { message: 'not found' }, if: -> { options.namespace }
  # TODO: Should there be validations for repository and source_repository?
  # validates :service, presence: { message: 'not found' }, if: -> { arguments.service }
  # validate :all_services, if: -> { arguments.services }
  # validates :runtime, presence: true

  def update(opts)
    file_config.merge!(opts)
    file_config.save
  end

  def file_config
    @file_config ||= Config.load_file('cnfs.yml')
  end

  def paths
    @paths ||= super&.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
  end

  def set_from_options(options)
    self.options = options
    self.environment = environments.find_by(name: options.environment) if options.environment
    self.namespace = environment.namespaces.find_by(name: options.namespace) if options.namespace
    self.repository = repositories.find_by(name: options.repository) if options.repository
    self.source_repository = repositories.find_by(name: options.source_repository) if options.source_repository
    self
  end

  # Returns a path relative from the project root
  # Example: write_path(:deployment) # => #<Pathname:tmp/cache/development/main>
  def write_path(type = :deployment)
    type = type.to_sym
    case type
    when :deployment
      paths.tmp.join('cache', *context_attrs)
    when :infra
      paths.data.join('infra', environment.name)
    when :runtime
      paths.tmp.join('runtime', *context_attrs)
    when :fixtures
      paths.tmp.join('dump')
    when :repositories
      paths.src
    when :config
      paths.config.join('environments', *context_attrs)
    end
  end

  # Used by runtime generators for templates by runtime to query services
  def labels
    { project: full_context_name, environment: environment&.name,  namespace: namespace&.name }
  end

  # def full_project_name
  def full_context_name
    context_attrs.unshift(name).join('_')
  end

  # def project_name
  def context_name
    context_attrs.join('_')
  end

  def context_attrs
    [environment&.name, namespace&.name].compact
  end

  class << self
    def parse
      yaml = YAML.load_file('cnfs.yml')
      output = { app: yaml.merge(namespace: "#{yaml['environment']}_#{yaml['namespace']}") }
      write_fixture(output)
    end
  end
end
