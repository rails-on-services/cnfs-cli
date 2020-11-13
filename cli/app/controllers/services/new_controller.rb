# frozen_string_literal: true

module Services
  class NewController < Thor
    OPTS = %i[noop quiet verbose]
    attr_accessor :action

    def self.default_repository
      # TODO: This is broken when calling cnfs new b/c repository_root returns nil
      # TODO: If there is no repository configured then it returns 'src'
      return '' unless ARGV[2]&.eql?('rails')
      # Cnfs.repository_root.split.last.to_s
    end

    def self.repo_options(repository = default_repository)
      path = Cnfs.paths.src.join(repository, '.cnfs.yml')
      hash = path.exist? ? YAML.load_file(path) : {}
      puts hash if Cnfs.config.debug.positive?
      Thor::CoreExt::HashWithIndifferentAccess.new(hash)
    end

    include Cnfs::Options
  end
end
