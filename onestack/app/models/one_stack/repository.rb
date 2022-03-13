# frozen_string_literal: true

module OneStack
  class Repository < ApplicationRecord
    # include Concerns::Operator
    include OneStack::Concerns::Generic
    include Hendrix::Git

    store :config, accessors: %i[url path]

    validates :url, presence: true

    after_destroy :remove_git_path

    def remove_git_path
      git_path.rmtree if git_path.exist?
    end

    # COMPONENT_PATH_KEY = 'components_path'
    # COMPONENT_FILE = 'component.yml'
    # REPOSITORY_FILE = 'repository.yml'

    # after_create :register_components

    # def register_components
    #   return unless repo.path.exist? && components_path_exist?
    #
    #   components_path.children.select(&:directory?).each do |component_path|
    #     next unless component_path.join(COMPONENT_FILE).exist?
    #
    #     component_name = component_path.relative_path_from(src_path).to_s
    #     OneStack.logger.info("Found component #{component_name}")
    #   end
    # end

    # def repo_path_exist?
    #   return true if path.exist?
    #
    #   log_f(:warn, "Repository #{name} path not found #{path}")
    #   nil
    # end

    # def components_path_exist?
    #   return true if components_path.exist?
    #
    #   log_f(:warn, "Invalid configuration for repository #{name}", "Path not found: #{components_path}")
    #   nil
    # end

    # # TODO: See about formatting messages using Logger config
    # def log_f(level, *messages)
    #   message = messages.shift
    #   m_messages = messages.map { |message| "\n#{' ' * 10}#{message}" }
    #   OneStack.logger.send(level, message, *m_messages)
    # end

    # def components_path() = path.join(components_path_name)

    # def components_path_name() = repo_config.fetch(COMPONENT_PATH_KEY, '.')

    # Return the contents of the repository's config file or an empty hash
    # def repo_config
    #   repo_config_file.exist? ? (YAML.load_file(repo_config_file) || {}) : {}
    # end

    # <path>/repository.yml if present must be in this specific location
    # def repo_config_file() = path.join(REPOSITORY_FILE)

    def git_url() = url

    def git_path() = @git_path ||= src_path.join(path || name)

    def src_path() = OneStack.config.paths.src

    def tree_name() = name

    class << self
      def init(context) = context.repositories.each { |repo| repo.git_clone }

      # def init(context)
      #   context.repositories.each do |repo|
      #     next if repo.git_path.exist?
      #
      #     msg = "Cloning repository #{repo.url} to #{repo.src_path}"
      #     OneStack.logger.info(msg)
      #
      #     OneStack.with_timer(msg) do
      #       repo.src_path.mkpath unless repo.src_path.exist?
      #       Dir.chdir(repo.src_path) { repo.git_clone(repo.url).run }
      #     end
      #   end
      # end

      # def add(param1, param2 = nil)
      #   url = name = nil
      #   if param1.match(git_url_regex)
      #     url = param1
      #     name = param2
      #   elsif (url = url_map[param1] || url_from_name(param1))
      #     # binding.pry
      #     name = param1.split('/').last
      #   end
      #   name ||= url.split('/').last&.delete_suffix('.git') if url
      #   new(name: name, url: url)
      # end

      # TODO: Move to cnfs-cli.yml
      # Shortcuts for CNFS repos
      # This is copied in to the user's local directory so its available to all projects on the file system
      # def url_map
      #   {
      #     cnfs: 'git@github.com:rails-on-services/ros.git',
      #     generic: 'git@github.com:rails-on-services/generic.git'
      #   }.with_indifferent_access
      # end

      # def url_from_name(name)
      #   path = name.eql?('.') ? OneStack.context.cwd.relative_path_from(OneStack.project.root) : Pathname.new(name)
      #   Dir.chdir(path) { remote.fetch_url } if path.directory?
      # end

      # Returns the default repository unless the the given path is another project repository
      # in which case return the Repository object that represents the given path
      # The default path is the directory where the command was invoked
      # def from_path(path = OneStack.context.cwd.to_s)
      #   src_path = OneStack.project_root.join(OneStack.paths.src).to_s
      #   return OneStack.project.repository if path.eql?(src_path) || !path.start_with?(src_path)
      #
      #   repo_name = path.delete_prefix(src_path).split('/')[1]
      #   OneStack.logger.debug("Identified repo name #{repo_name}")
      #   find_by(name: repo_name)
      # end
      #
      # def add_columns(t)
      #   t.string :dockerfile
      #   t.string :build
      # end
    end
  end
end
