# frozen_string_literal: true

class BlueprintsController < Thor
  include CommandHelper

  # Activate common options
  class_before :initialize_project
  cnfs_class_options :dry_run, :logging
  cnfs_class_options Project.first.command_options_list

  desc 'apply', 'Apply an infrastructure blueprint to create infrastructure'
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
