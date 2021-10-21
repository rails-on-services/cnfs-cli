# frozen_string_literal: true

class RepositoriesController < Thor
  include CommandHelper

  # Activate common options
  cnfs_class_options :dry_run, :logging
  class_before :initialize_project

  register Repositories::CreateController, 'create', 'create TYPE NAME [options]', 'Create a new CNFS compatible services repository'

  desc 'add [NAME | URL [NAME]]', 'Add a repository configuration to the project'
  option :init, desc: 'Initialize repository',
                       aliases: '-i', type: :boolean
  def add(p1, p2 = nil)
    repo = Repository.add(p1, p2)
    raise Cnfs::Error, repo.errors.full_messages.join("\n") unless repo.save

    init(repo.name) if options.init
    # If this is the first source repository added to the project then make it the default
    # repo.project.update(source_repository: repo.name) if repo.project.source_repository.nil?
  end

  desc 'new_add [NAME | URL [NAME]]', 'Add a repository configuration to the project'
  def new_add(p1, p2 = nil)
    repo = Repository.add(p1, p2)
    repo.save
  end

  desc 'destroy [NAME]', 'Delete a repository configuration and its contents from the project'
  cnfs_options :force
  before :validate_destroy
  def destroy(name)
    raise Cnfs::Error, "Repository #{name} not found" unless (repo = Repository.find_by(name: name))

    repo.remove_tree
    repo.destroy
  end

  desc 'init [NAME]', 'Initialize (clone) a configured repository'
  def init(name)
    raise Cnfs::Error, "Repository not found: '#{name}'" unless (repo = Repository.find_by(name: name))

    raise Cnfs::Error, "Directory already exists at '#{repo.full_path}'" if repo.full_path.exist?

    return if options.dry_run

    Cnfs.project.paths.src.mkpath # Ensure the project's repositories directory exists
    Dir.chdir(Cnfs.project.paths.src) do
      %x(#{repo.clone_cmd})
      repo.update(type: 'Repository::Rails')
      if repo.full_path.join('.cnfs').exist?
        config = YAML.load_file(repo.full_path.join('.cnfs'))
        repo.update(type: config[:type])
        repo = Repository.find_by(name: name)
        repo.after_init if repo.respond_to?(:after_init)
      end
    end
  end

  desc 'list', 'List repositories and services'
  map %w[ls] => :list
  def list
    require 'tty-tree'
    data = Repository.order(:name).each_with_object({}) do |repo, hash|
      hash[repo.name] = repo.services_path.exist? ? repo.services_path.children.select(&:directory?) : {}
    end
    puts TTY::Tree.new(data).render
  end

  desc 'remove [NAME]', 'Remove a repository configuration from the project'
  # cnfs_options :force
  # before :validate_destroy
  map %w[rm] => :remove
  def remove(name)
    raise Cnfs::Error, "Repository #{name} not found" unless (repo = Repository.find_by(name: name))

    repo.destroy
  end

  desc 'show [NAME]', 'Show repository configuration details'
  def show(name)
    raise Cnfs::Error, "Repository #{name} not found" unless (repo = Repository.find_by(name: name))

    puts repo.name
    puts repo.config
  end
end
