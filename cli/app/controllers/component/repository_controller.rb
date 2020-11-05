# frozen_string_literal: true

module Component
  class RepositoryController < Thor

    desc 'rails', 'Add a CNFS compatible backend services repository based on the Ruby on Rails Framework'
    option :database, desc: 'Preconfigure for selected database (options: postgresql)',
      aliases: '-D', type: :string, default: 'postgresql'
    # TODO: Add options that carry over to the rails plugin new command
    def rails(name)
      with_context(name) do
        create_repository(:rails, name)
      end
    end

    desc 'angular', 'Add a CNFS compatible frontend client repository based on the Angular Framework'
    def angular(name)
      with_context(name) do
        create_repository(:angular, name)
      end
    end

    desc 'url', 'Add a CNFS compatible repository (used for development)'
    def url(url, name = nil)
      # Shortcut for CNFS backend repo 
      url = 'git@github.com:rails-on-services/ros.git' if url.eql?('ros')
      # git_url_regex = /^(([A-Za-z0-9]+@|http(|s)\:\/\/)|(http(|s)\:\/\/[A-Za-z0-9]+@))([A-Za-z0-9.]+(:\d+)?)(?::|\/)([\d\/\w.-]+?)(\.git){1}$/i
      name ||= url.split('/').last&.delete_suffix('.git')
      return unless name

      with_context(name) do
        clone_repository(url, name)
      end
    end

    private

    def with_context(name)
      Cnfs.paths.src.mkpath
      current_repo_count = Cnfs.paths.src.children.size
      yield
      if current_repo_count.zero?
        o = Config.load_file('cnfs.yml')
        o.repository = name
        o.save
      end
    end

    def create_repository(type, name)
      generator_name = "#{type}/repository_generator"
      unless (generator_class = generator_name.classify.safe_constantize)
        raise Cnfs::Error, set_color("#{generator_name} class not found. This is a bug. please report", :red) 
      end

      generator = generator_class.new(['restogy', name], options)
      generator.destination_root = Cnfs.paths.src.join(name)
      generator.invoke_all

      update_config(name, repo_type: type)
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

    def update_config(name, config = {})
      o = Config.load_file(Cnfs.paths.config.join('repositories.yml'))
      o[name] = { config: config }
      o.save
    end
  end
end
