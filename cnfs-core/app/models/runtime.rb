# frozen_string_literal: true

class Runtime < ApplicationRecord
  has_many :targets

  store :config, accessors: %i[version], coder: YAML

  # Attributes configured by the command object
  # attr_accessor :cmd, :deployment, :application, :target
  attr_accessor :controller, :target

  # Sub-classes, e.g. compose, skaffold can override to implement, e.g. switch!
  def before_execute_on_target; end

  # TODO: fully implement so when down is called that all runtime and docs are revmoed
  # TODO: creds_file is in credentials controller
  def remove_cache(service = nil)
    if service.eql?('iam')
      FileUtils.rm(creds_file) if File.exist?(creds_file)
    elsif service.nil?
      FileUtils.rm_rf(runtime_dir)
    end
  end
end
