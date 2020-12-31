# frozen_string_literal: true

class BuildsController < Thor
  include CommandHelper

  cnfs_class_options :dry_run, :logging
  class_before :initialize_project
  # class_before :ensure_valid_project

  desc 'apply', 'Apply a build'
  def apply(name)
    execute({ name: name }, :crud, 2, :apply)
  end

  desc 'create', 'Create an infrastructure blueprint for an environment'
  def create
    execute({}, :crud, 2, :create)
  end

  desc 'delete NAME', 'Delete an infrastructure blueprint'
  def delete(name)
    execute({ name: name }, :crud, 2, :delete)
  end

  desc 'describe NAME', 'Describe an infrastructure blueprint'
  def describe(name)
    execute({ name: name }, :crud, 2, :describe)
  end

  desc 'list', 'List infrastructure blueprints'
  def list
    execute({}, :crud, 2, :list)
  end

  desc 'update NAME', 'Update an infrastructure blueprint'
  def update(name)
    execute({ name: name }, :crud, 2, :update)
  end
end
