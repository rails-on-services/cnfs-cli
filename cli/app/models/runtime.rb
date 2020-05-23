# frozen_string_literal: true

class Runtime < ApplicationRecord
  has_many :targets

  store :config, accessors: %i[version], coder: YAML

  # Attributes configured by the controller
  # attr_accessor :controller, :target
  # attr_accessor :context, :target, :response
  attr_accessor :context, :response

  # method inherited from A/R base interferes with controller#destroy
  undef_method :destroy

  def supported_commands
    raise NotImplementedError, 'To implement: returns an array of commans names supported by this runtime'
  end

  # Sub-classes, e.g. compose, skaffold override to implement, e.g. switch!
  def before_execute_on_target
    raise NotImplementedError, 'this needs to be done'
  end

  def clean_cache
    if context.selected_services.empty?
      FileUtils.rm_rf(runtime_path)
      return
    end

    context.selected_services.each do |service|
      migration_file = "#{runtime_path}/#{service.name}-migrated"
      FileUtils.rm(migration_file) if File.exist?(migration_file)
      FileUtils.rm(credentials[:local_file]) if service.name.eql?('iam') && File.exist?(credentials[:local_file])
    end
  end

  def credentials
    { remote_file: '/home/rails/services/app/tmp/mounted/credentials.json',
      local_file: "#{runtime_path}/target/credentials.json",
      local_path: "#{runtime_path}/target" }
  end

  def deployment_path
    @deployment_path ||= context.write_path(:deployment)
  end

  def runtime_path
    @runtime_path ||= context.write_path(:runtime)
  end

  def generator_class
    "Runtime::#{type.demodulize}Generator".safe_constantize
  end

  def project_name
    # [Cnfs.application.class.name.underscore.split('/').shift, context.target.name, context.target.application.name].join('_')
    context.project_name
  end
end
