# frozen_string_literal: true

class Project < ApplicationRecord
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

  # If options were passed in then ensure the values are valid (names found in the config)
  validates :environment, presence: { message: 'not found' } #, if: -> { options.environment }
  validates :namespace, presence: { message: 'not found' } # , if: -> { options.namespace }
  # TODO: Should there be validations for repository and source_repository?
  # validates :service, presence: { message: 'not found' }, if: -> { arguments.service }
  # validate :all_services, if: -> { arguments.services }
  # validates :runtime, presence: true

  validate :repository_is_valid

  def repository_is_valid
    # binding.pry
    #aise Cnfs::Error, "Unknown repository '#{options.repository}'." \
    #  " Valid repositories:\n#{Cnfs.repositories.keys.join("\n")}"
  end

  # TODO: Implement options.clean
  # NOTE: If this method is called more than once it will get a new manifest instance each time
  def process_manifests
    @manifest = nil
    manifest.purge! if options.clean
    return if manifest.valid?

    manifest.generate
  end

  # TODO: add other dirs for config files, e.g. gem user's path; load from a config file?
  def manifest
    @manifest ||= Manifest.new(project: self, config_files_paths: [paths.config])
  end

  # Used by all runtime templates; Returns a path relative from the write path to the project root
  # Example: relative_path(:deployment) # => #<Pathname:../../../..>
  def relative_path(path_type = :deployment)
    Cnfs.project_root.relative_path_from(Cnfs.project_root.join(write_path(path_type)))
  end

  def x_relative_path(path)
    Cnfs.project_root.relative_path_from(Cnfs.project_root.join(path))
  end

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

  # TODO: See what to do about this
    # scope is either :namespace or :environment
    def encrypt(plaintext, scope)
      send(scope).encrypt(plaintext)
    end

    def decrypt(ciphertext)
      namespace.decrypt(ciphertext)
    rescue Lockbox::DecryptionError => e
      environment.decrypt(ciphertext)
    end

  class << self
    def parse
      content = Cnfs.config.to_hash.slice(*reflect_on_all_associations(:belongs_to).map(&:name).append(:name, :paths, :tags))
      namespace = "#{content[:environment]}_#{content[:namespace]}"
      options = Cnfs.config.delete_field(:options).to_hash if Cnfs.config.options
      output = { app: content.merge(namespace: namespace, options: options) }
      write_fixture(output)
    end

    # Determine the current repository from where the user is in the project filesystem
    # Returns the default repository unless the user is in the path of another project repository
    # rubocop:disable Metrics/AbcSize
    def current_repository
      current_path = Cnfs.cwd.to_s
      src_path = Cnfs.project_root.join(paths.src).to_s
      # return app.repository if current_path.eql?(src_path) || !current_path.start_with?(src_path)
      return if current_path.eql?(src_path) || !current_path.start_with?(src_path)

      repo_name = current_path.delete_prefix(src_path).split('/')[1]
      app.repositories.find_by(name: repo_name)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
