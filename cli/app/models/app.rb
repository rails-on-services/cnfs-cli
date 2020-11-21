# frozen_string_literal: true

class App < ApplicationRecord
  attr_accessor :manifest

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
  store :options, coder: YAML

  after_initialize do
    # self.manifest ||= Manifest.new(config_files_paths: [paths.config], manifests_path: write_path)
  end

  # If options were passed in then ensure the values are valid (names found in the config)
  validates :environment, presence: { message: 'not found' } #, if: -> { options.environment }
  validates :namespace, presence: { message: 'not found' } # , if: -> { options.namespace }
  # TODO: Should there be validations for repository and source_repository?
  # validates :service, presence: { message: 'not found' }, if: -> { arguments.service }
  # validate :all_services, if: -> { arguments.services }
  # validates :runtime, presence: true

  # TODO: This may be unnecessary or a very important method/scope. Think about this
  def services; namespace.services end
  def runtime; environment.runtime end 

  # NOTE: Not yet in use; decide where this should go
  def user_root
    @user_root ||= Cnfs.user_root.join(name)
  end

  def update(opts)
    file_config.merge!(opts)
    file_config.save
  end

  def file_config
    @file_config ||= Config.load_file(Cnfs::PROJECT_FILE)
  end

  def options
    @options ||= Thor::CoreExt::HashWithIndifferentAccess.new(super)
  end

  def paths
    @paths ||= super&.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
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

  def full_context_name
    context_attrs.unshift(name).join('_')
  end

  def context_name
    context_attrs.join('_')
  end

  def context_attrs
    [environment&.name, namespace&.name].compact
  end

  class << self
    def parse
      content = Cnfs.config.to_hash.slice(*reflect_on_all_associations(:belongs_to).map(&:name).append(:name, :paths))
      namespace = "#{content[:environment]}_#{content[:namespace]}"
      options = Cnfs.config.delete_field(:options).to_hash
      output = { app: content.merge(namespace: namespace, options: options) }
      write_fixture(output)
    end
  end
end
