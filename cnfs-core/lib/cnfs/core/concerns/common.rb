# frozen_string_literal: true

module Cnfs::Core::Concerns
  module Common
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def children
        constants.map do |p|
          p.to_s.underscore
        end.reject { |m| %w[class_methods templates generator].include?(m) }
      end
    end

    def provider; config.providers[config.provider] end

    def settings; parent.settings[name] end

    def children; self.class.children end

    # TODO: This could be a class that has methods like env name
    # and wraps settings in an attribute
    # with a method missing that sends to that attribute
    def config
      parent.config.merge!(settings.config&.to_hash)
    end

    def environment
      parent.environment.merge!(settings.environment&.to_hash)
    end

    def to_h; settings.to_hash end

    def to_env; settings.to_env end

    def name; @name ||= self.class.name.split('::').last.split(/(?=[A-Z])/).join('_').downcase end

    # TODO:
    def env_name(delimiter = '-'); [config.env, config.profile, config.feature_set].compact.join(delimiter) end

    def registry_secret_name; "registry-#{config.image_registry}" end

    # NOTE: This is the default implementation; Can be overridden by a Partition, Component or Resource
    def image_tag; [version, image_prefix, git.sha].compact.join('-') end

    # def version; Dir.chdir(Ros.root) { Bump::Bump.current } end
    def version; '0.99' end

    # NOTE: image_prefix is specific to the resource so the default implementation is to return nil
    def image_prefix; end

    def git; @git ||= git_details end

    def git_details
      return Config::Options.new unless system('git rev-parse --git-dir > /dev/null 2>&1')
      Config::Options.new(
        tag_name: %x(git tag --points-at HEAD).chomp,
        branch_name: %x(git rev-parse --abbrev-ref HEAD).strip.gsub(/[^A-Za-z0-9-]/, '-'),
        sha: %x(git rev-parse --short HEAD).chomp
      )
    end

    def root
      @root ||= (cwd = Dir.pwd
        while not cwd.eql?('/')
          break Pathname.new(cwd) if File.exist?("#{cwd}/config/cnfs.yml")
          cwd = File.expand_path('..', cwd)
        end)
    end

    def cnfs_root; is_cnfs? ? root : root.join('ros') end

    def has_cnfs?; not is_cnfs? and Dir.exists?(cnfs_root) end

    # TODO: This is a hack in order to differentiate for purpose of templating files
    def is_cnfs?
      config.image_registry.eql?('railsonservices') and config.partition_name.eql?('cnfs')
    end
  end
end
