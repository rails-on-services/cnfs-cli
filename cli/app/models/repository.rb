# frozen_string_literal: true

# require 'active_record'
class Repository < ApplicationRecord
  include Concerns::Asset

    def search_paths
      [Cnfs.paths.src.join(name).join('.cnfs/config')]
    end

  # belongs_to :owner, polymorphic: true
  # has_many :services, as: :owner

  # store :config, accessors: %i[url repo_type], coder: YAML
  store :config, accessors: %i[url], coder: YAML

  validates :name, presence: true
  validates :url, presence: true

  after_create :create_node

  def create_node
    # puts "# This gets called when a node creates a repo #{__FILE__}"
    # So going in the other direction have to avoid an infinite loop
    # binding.pry
  end

  # after_destroy :remove_tree

  # def services
  #   services_path.exist? ? services_path.children.select(&:directory?).map { |p| p.split.last.to_s } : []
  # end

  def services_path
    full_path.join('services')
  end

  # def git
  #   Dir.chdir(full_path) { Cnfs.git }
  # end

  def as_save
    attributes.slice('name', 'config', 'type')
  end

  def clone_cmd
    "git clone #{url} #{name}"
  end

  def remove_tree
    full_path.rmtree if full_path.exist?
  end

  def full_path
    paths.src.join(name)
  end

  def paths
    Cnfs.project.paths
  end

  class << self
    def add(param1, param2 = nil)
      url = name = nil
      if param1.match(git_url_regex)
        url = param1
        name = param2
      elsif (url = url_map[param1] || url_from_name(param1))
        # binding.pry
        name = param1.split('/').last
      end
      name ||= url.split('/').last&.delete_suffix('.git') if url
      new(name: name, url: url)
    end

    # rubocop:disable Layout/LineLength
    def git_url_regex
      %r{^(([A-Za-z0-9]+@|http(|s)://)|(http(|s)://[A-Za-z0-9]+@))([A-Za-z0-9.]+(:\d+)?)(?::|/)([\d/\w.-]+?)(\.git){1}$}i
    end
    # rubocop:enable Layout/LineLength

    # Shortcuts for CNFS repos
    def url_map
      {
        cnfs: 'git@github.com:rails-on-services/ros.git',
        generic: 'git@github.com:rails-on-services/generic.git'
      }.with_indifferent_access
    end

    def url_from_name(name)
      path = name.eql?('.') ? Cnfs.context.cwd.relative_path_from(Cnfs.project.root) : Pathname.new(name)
      Dir.chdir(path) { remote.fetch_url } if path.directory?
    end

    def remote
      remote = `git remote -v`.split("\t")
      return OpenStruct.new if remote.blank?

      OpenStruct.new(name: remote[0], fetch_url: remote[1].split[0], push_url: remote[2].split[0])
    end

    # Returns the default repository unless the the given path is another project repository
    # in which case return the Repository object that represents the given path
    # The default path is the directory where the command was invoked
    def from_path(path = Cnfs.context.cwd.to_s)
      src_path = Cnfs.project_root.join(Cnfs.paths.src).to_s
      return Cnfs.project.repository if path.eql?(src_path) || !path.start_with?(src_path)

      repo_name = path.delete_prefix(src_path).split('/')[1]
      Cnfs.logger.debug("Identified repo name #{repo_name}")
      find_by(name: repo_name)
    end

    def add_columns(t)
      t.string :context
      t.string :dockerfile
      t.string :build
      t.string :type
      t.string :tags
    end
  end
end
