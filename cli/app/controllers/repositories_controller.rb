# frozen_string_literal: true

class RepositoriesController < Thor
  include Cnfs::Options
  include Repositories::Concern

  # Activate common options
  cnfs_class_options :noop, :quiet, :verbose, :force

  register Repositories::NewController, 'new', 'new TYPE NAME [options]', 'Create a new repoository'

  desc 'add URL [NAME]', 'Add a remote CNFS compatible services repository'
  def add(url, name = nil)
    # Shortcut for CNFS backend repo 
    if (mapped_url = url_map[url.to_sym])
      url = mapped_url
    end
    # git_url_regex = /^(([A-Za-z0-9]+@|http(|s)\:\/\/)|(http(|s)\:\/\/[A-Za-z0-9]+@))([A-Za-z0-9.]+(:\d+)?)(?::|\/)([\d\/\w.-]+?)(\.git){1}$/i
    name ||= url.split('/').last&.delete_suffix('.git')
    return unless name

    with_context(name) do
      clone_repository(url, name)
    end
  end

  desc 'list', 'List repositories and services'
  def list
    return unless Cnfs.paths.src.exist?

    Cnfs.paths.src.children.select{ |e| e.directory? }.sort.each do |repo|
      puts repo.split.last
      next unless repo.join('services').exist?

      puts repo.join('services').children.select{ |e| e.directory? }.map{ |path| "> #{path.split.last}" }.sort
    end
  end

  desc 'remove NAME', 'Remove a repository from the project'
  def remove(name)
    return unless (options.force || yes?("\n#{'WARNING!!!  ' * 5}\nThis will destroy the repository.\nAre you sure?"))

    Cnfs.require_deps
    Cnfs.require_project!(arguments: {}, options: options, response: nil)
    raise Cnfs::Error, "Repository #{name} not found" unless (repo = Repository.find_by(name: name))

    repo.delete
  end

  private

  def url_map
    {
      cnfs: 'git@github.com:rails-on-services/ros.git',
      generic: 'git@github.com:rails-on-services/generic.git'
    }
  end

  # NOTE: URL based rails repositories contain services with Gemfiles that have the gem and the path
  def clone_repository(url, name)
    cmd = "git clone #{url} #{name}"
    # TODO: Use the response object to run the command
    puts cmd if options.debug.positive? or options.verbose
    Dir.chdir(Cnfs.paths.src) { `#{cmd}` } unless options.noop

    # TODO: Get the config from a file in the just cloned repository
    update_config(name, url: url)
  end
end
