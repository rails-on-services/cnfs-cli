# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Project < ApplicationRecord
  include Concerns::Component

  # attr_accessor :runtime
  attr_writer :manifest

  belongs_to :environment
  belongs_to :namespace
  belongs_to :repository
  belongs_to :source_repository, class_name: 'Repository'

  has_many :environments, as: :owner
  has_many :stacks, as: :owner

  # TODO: Review if these models should have an owner; do they belong to project? or any component? or none?
  has_many :builders, as: :owner
  has_many :providers, as: :owner
  has_many :users, as: :owner

  # has_many :runtimes
  # has_many :repositories
  # has_many :namespaces, through: :environments

  store :paths, coder: YAML
  store :options, coder: YAML

  # If options were passed in then ensure the values are valid (names found in the config)
  # validates :environment, presence: { message: 'not found' } # , if: -> { options.environment }
  # validates :namespace, presence: { message: 'not found' } # , if: -> { options.namespace }
  # validate :associations_are_valid

  # TODO: Should there be validations for repository and source_repository?
  # validates :service, presence: { message: 'not found' }, if: -> { arguments.service }
  # validate :all_services, if: -> { arguments.services }
  # validates :runtime, presence: true

  def associations_are_valid
    # errors.copy!(environment.errors) unless environment.valid?
  end

  def repository_is_valid
    # binding.pry
    # raise Cnfs::Error, "Unknown repository '#{options.repository}'." \
    #  " Valid repositories:\n#{Cnfs.repositories.keys.join("\n")}"
  end

  # TODO: Implement validation
  def platform_is_valid
    errors.add(:platform, 'not supported') if Cnfs.platform.unknown?
  end

  # TODO: Implement options.clean
  # NOTE: If this method is called more than once it will get a new manifest instance each time
  def process_manifests
    @manifest = nil
    manifest.purge! if options.force
    return if manifest.valid?

    manifest.generate
  end

  # TODO: add other dirs for config files, e.g. gem user's path; load from a config file?
  def manifest
    @manifest ||= Manifest.new(project: self, config_files_paths: [paths.config])
  end

  # TODO: This may be unnecessary or a very important method/scope. Think about this
  # def services
  #   namespace.services
  # end

  # def runtime; environment.runtime end
  def blueprints
    environment.blueprints
  end

  # NOTE: Not yet in use; decide where this should go
  def user_root
    @user_root ||= Cnfs.user_root.join(name)
  end

  def as_save
    base = attributes.slice('name', 'config', 'paths', 'logging')
    # base.merge!('repository' => "#{repository.name} (#{repository.type})") if repository
    base.merge!('repository' => repository.name) if repository
    base
  end

  def _source
    'config/project.yml'
  end

  def options
    @options ||= Thor::CoreExt::HashWithIndifferentAccess.new(super)
  end

  def paths
    @paths ||= super&.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
  end

  # maintain api for now
  def write_path(type = :manifests)
    path(to: type)
  end

  def path(from: nil, to: nil, absolute: false)
    project_path.path(from: from, to: to, absolute: absolute)
  end

  def project_path
    @project_path ||= ProjectPath.new(self)
  end

  def root
    Cnfs.project_root
  end

  # Used by runtime generators for templates by runtime to query services
  def labels
    { project: full_context_name, environment: environment&.name, namespace: namespace&.name }
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

  # TODO: See what to do about encrypt/decrypt per env/ns

  # Returns an encrypted string
  #
  # ==== Parameters
  # plaintext<String>:: the string to be encrypted
  # scope<String>:: the encryption key to be used: environment or namespace
  def encrypt(plaintext, scope)
    send(scope).encrypt(plaintext)
  end

  def decrypt(ciphertext)
    namespace.decrypt(ciphertext)
  rescue Lockbox::DecryptionError => _e
    environment.decrypt(ciphertext)
  end

  class << self
    # def parse
    #   content = Cnfs.config.to_hash.slice(
    #     *reflect_on_all_associations(:belongs_to).map(&:name).append(:name, :paths, :tags)
    #   )
    #   namespace = "#{content[:environment]}_#{content[:namespace]}"
    #   options = Cnfs.config.delete_field(:options).to_hash if Cnfs.config.options
    #   output = { 'project' => content.merge(namespace: namespace, options: options) }
    #   create_all(output)
    # end

    def create_table(schema)
      schema.create_table :projects, force: true do |t|
        t.string :context
        t.references :environment
        t.references :namespace
        t.references :repository
        t.references :source_repository
        t.string :name
        t.string :config
        t.string :options
        t.string :paths
        t.string :tags
        t.string :logging
        t.string :_source
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
