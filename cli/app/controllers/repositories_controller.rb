# frozen_string_literal: true

class RepositoriesController < Thor
  include CommandHelper
  include RepositoryHelper

  # Activate common options
  cnfs_class_options :noop, :quiet, :verbose
  class_before :initialize_project

  register Repositories::NewController, 'new', 'new TYPE NAME [options]', 'Create a new repoository'

  desc 'add URL [NAME]', 'Add a remote CNFS compatible services repository'
  def add(url, name = nil)
    Repository.add(url, name)
  end

  desc 'list', 'List repositories and services'
  def list
    puts Repository.pluck(:name)
    # return unless Cnfs.app.paths.src.exist?

    # Cnfs.app.paths.src.children.select(&:directory?).sort.each do |repo|
    #   puts repo.split.last
    #   next unless repo.join('services').exist?

    #   puts repo.join('services').children.select(&:directory?).map { |path| "> #{path.split.last}" }.sort
    # end
  end

  desc 'remove NAME', 'Remove a repository from the project'
  cnfs_options :force
  before :validate_destroy
  def remove(name)
    raise Cnfs::Error, "Repository #{name} not found" unless (repo = Repository.find_by(name: name))

    repo.delete
  end
end
