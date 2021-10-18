# frozen_string_literal: true

class Project < ApplicationRecord
  # include Singleton
  include Concerns::Component

  # belongs_to :source_repository, class_name: 'Repository'

  # has_many :blueprints, as: :owner
  # has_many :builders, as: :owner
  # has_many :providers, as: :owner
  # has_many :repositories
  # has_many :runtimes
  # has_many :users, as: :owner

  store :paths, coder: YAML
  serialize :components, Array
  # store :options, coder: YAML

  # called by Component concern
  def owner; end

  # TODO: Implement validation
  def platform_is_valid
    errors.add(:platform, 'not supported') if Cnfs.platform.unknown?
  end

  def search_config
    { path: Pathname.new(parent.path).split[0].join('config'),
      asset_names: %w[builders context providers resources repositories runtimes services users],
      component_names: Cnfs.config.order }
  end

  def paths
    @paths ||= super&.each_with_object(OpenStruct.new) { |(k, v), os| os[k] = Pathname.new(v) }
  end

  def root
    Cnfs.project_root
  end

  # TODO: This may be unnecessary or a very important method/scope. Think about this
  # def services
  #   namespace.services
  # end

  # NOTE: Not yet in use; decide where this should go
  # def user_root
  #   @user_root ||= Cnfs.user_root.join(name)
  # end

  def as_save
    base = attributes.slice('name', 'config', 'paths', 'logging')
    # base.merge!('repository' => "#{repository.name} (#{repository.type})") if repository
    base.merge!('repository' => repository.name) if repository
    base
  end

  # def _source
  #   'config/project.yml'
  # end

  # def options
  #   @options ||= Thor::CoreExt::HashWithIndifferentAccess.new(super)
  # end

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
    def add_columns(t)
      t.string :order
      t.string :paths
      t.string :components
      t.string :tags
      t.string :logging
    end
  end
end
