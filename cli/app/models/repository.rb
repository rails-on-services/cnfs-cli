# frozen_string_literal: true

class Repository < Component
  include Concerns::Git
  # include Concerns::Taggable

  store :config, accessors: %i[url], coder: YAML

  validates :url, presence: true

  def dir_path
    CnfsCli.configuration.paths.src.join(name)
  end

  def git
    Dir.chdir(dir_path) { super }
  end

  def clone_it
    Command.new(exec: "git clone #{url} #{dir_path}").run
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

    # TODO: Move to cnfs-cli.yml
    # Shortcuts for CNFS repos
    # This is copied in to the user's local directory so its available to all projects on the file system
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
      t.string :dockerfile
      t.string :build
    end
  end
end
