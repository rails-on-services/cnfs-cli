# frozen_string_literal: true

class BuildsController < Thor
  include CommandHelper

  cnfs_class_options :dry_run, :logging
  class_before :initialize_project
  # class_before :ensure_valid_project

  desc 'apply', 'Run packer on a configured build'
  def apply(name)
    execute({ name: name }, :crud, 2, :apply)
  end

  desc 'create', 'Create a new build configuration'
  def create
    execute({}, :crud, 2, :create)
  end

  desc 'delete NAME', 'Delete a build configuration and its associated builders, provisioners and post-processors'
  def delete(name)
    execute({ name: name }, :crud, 2, :delete)
  end

  desc 'describe NAME', 'Describe an build configuration'
  def describe(name)
    execute({ name: name }, :crud, 2, :describe)
  end

  desc 'list', 'List build configurations'
  def list
    execute({}, :crud, 2, :list)
  end

  desc 'update NAME', 'Update a build configuration'
  def update(name)
    execute({ name: name }, :crud, 2, :update)
  end
end
