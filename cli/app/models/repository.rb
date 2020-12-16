# frozen_string_literal: true

class Repository < ApplicationRecord
  include BelongsToProject

  has_many :services

  store :config, accessors: %i[url repo_type], coder: YAML

  validates :name, presence: true
  validates :url, presence: true

  after_destroy :remove_tree
  # TODO: Validate the url is a proper git pattern:
  # git_url_regex = /^(([A-Za-z0-9]+@|http(|s)\:\/\/)|(http(|s)\:\/\/[A-Za-z0-9]+@))([A-Za-z0-9.]+(:\d+)?)(?::|\/)([\d\/\w.-]+?)(\.git){1}$/i

  parse_sources :project, :user

  # def services
  #   services_path.exist? ? services_path.children.select(&:directory?).map { |p| p.split.last.to_s } : []
  # end

  def services_path
    path.join('services')
  end

  def path
    @path ||= paths.src.join(name)
  end

  def git
    Dir.chdir(path) { Cnfs.git }
  end

  def clone
    # Ensure the project's repositories directory exists
    paths.src.mkpath
    if paths.src.join(name).exist?
      Cnfs.logger.info("Repository already exists at #{name}")
      return
    end

    cmd = "git clone #{url} #{name}"
    Cnfs.logger.debug(cmd)
    # TODO: Use the response object to run the command?
    Dir.chdir(paths.src) { `#{cmd}` } unless options.noop
    true
  end

  # for save/delete
  def as_save
    { name => attributes.slice('name', 'config') }
  end

  def remove_tree
    full_path.rmtree if full_path.exist?
  end

  def full_path
    paths.src.join(name)
  end

  class << self
    def add(url, name)
      if (mapped_url = url_map[url.to_sym])
        url = mapped_url
      end
      name ||= url.split('/').last&.delete_suffix('.git')
      repo = new(name: name, url: url)
      return unless repo.valid? and repo.clone

      repo.save
      # If this is the first source repository added to the project then make it the default
      repo.project.update(source_repository: repo.name) if repo.project.source_repository.nil?
    end

    # Shortcuts for CNFS repos
    def url_map
      {
        cnfs: 'git@github.com:rails-on-services/ros.git',
        generic: 'git@github.com:rails-on-services/generic.git'
      }
    end

    # def dirs
    #   ['config']
    # end

    # TODO: Does still need to read the repoistory info
    # def x_parse
    #   src = Pathname.new('src')
    #   output = dirs.each_with_object({}) do |dir, hash|
    #     file = "#{dir}/#{table_name}.yml"
    #     next unless File.exist?(file)

    #     yaml = YAML.load_file(file)
    #     yaml.each do |k, v|
    #       repo_path = src.join(k)
    #       Cnfs.logger.info "Scanning repository path #{repo_path}"
    #       repo_config_path = repo_path.join('cnfs/repository.yml')
    #       repo_yaml = {}
    #       if repo_config_path.exist?
    #         Cnfs.logger.info "Loading repository path #{repo_path}"
    #         repo_yaml = YAML.load_file(repo_config_path).merge(path: repo_path.to_s)
    #         repo_yaml.merge!('type' => "repository/#{repo_yaml['type']}".classify)
    #       end
    #       hash[k] = v.merge(name: k, project: 'app').merge(repo_yaml)
    #     end
    #   end
    #   write_fixture(output)
    # end

    def create_table(s)
      s.create_table :repositories, force: true do |t|
        t.references :project
        t.string :config
        t.string :name
        t.string :namespace
        t.string :path
        t.string :service_type
        t.string :test_framework
        t.string :type
        t.string :tags
      end
    end
  end
end
