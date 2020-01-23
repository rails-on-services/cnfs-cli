# frozen_string_literal: true
# require 'open3'

class Runtime < ApplicationRecord
  has_many :targets

  store :config, accessors: %i[version], coder: YAML

  # Attributes configured by the controller
  # attr_accessor :controller, :target
  attr_accessor :target, :request, :response

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
    if request.services.empty?
      FileUtils.rm_rf(runtime_path)
      return
    end

    request.services.each do |service|
      migration_file = "#{runtime_path}/#{service.name}-migrated"
      FileUtils.rm(migration_file) if File.exist?(migration_file)
      FileUtils.rm(credentials[:local_file]) if service.name.eql?('iam') and File.exist?(credentials[:local_file])
    end
  end

  def credentials
    { remote_file: "/home/rails/services/app/tmp/#{'mounted'}/credentials.json",
      local_file: "#{runtime_path}/target/credentials.json",
      local_path: "#{runtime_path}/target" }
  end

  def runtime_path; @runtime_path ||= target.write_path(:runtime) end

  def project_name; [Cnfs.project_name, target.name, target.application.name].join('_') end
end
