# frozen_string_literal: true

class Runtime < ApplicationRecord
  belongs_to :app
  # has_many :targets


  class << self
    def dirs
      [Cnfs.gem_root.join('config').to_s]
    end
  end

  store :config, accessors: %i[version], coder: YAML

  # Attributes configured by the controller
  attr_accessor :application, :response, :options

  # method inherited from A/R base interferes with controller#destroy
  undef_method :destroy

  def supported_commands
    raise NotImplementedError, 'To implement: returns an array of command names supported by this runtime'
  end

  # Sub-classes, e.g. compose, skaffold override to implement, e.g. switch!
  def before_execute
    raise NotImplementedError, 'this needs to be done'
  end

  def labels(labels)
    application.labels.merge(labels)
  end

  def context_service_names
    application.arguments.services
  end

  def context_service_name
    application.arguments.service
  end

  def clean_cache
    # NOTE: Who calls this method?
    if application.selected_services.empty?
      FileUtils.rm_rf(runtime_path)
      return
    end

    context_service_names.each do |service_name|
      migration_file = "#{runtime_path}/#{service_name}-migrated"
      FileUtils.rm(migration_file) if File.exist?(migration_file)
      FileUtils.rm(credentials[:local_file]) if service_name.eql?('iam') && File.exist?(credentials[:local_file])
    end
  end

  def credentials
    { remote_file: '/home/rails/services/app/tmp/mounted/credentials.json',
      local_file: "#{runtime_path}/target/credentials.json",
      local_path: "#{runtime_path}/target" }
  end

  def deployment_path
    @deployment_path ||= application.write_path(:deployment)
  end

  def runtime_path
    @runtime_path ||= application.write_path(:runtime)
  end

  def generator_class
    "Runtime::#{type.demodulize}Generator".safe_constantize
  end

  def project_name
    application.project_name
  end
end
