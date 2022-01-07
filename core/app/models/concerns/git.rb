# frozen_string_literal: true

module Concerns
  module Git
    extend ActiveSupport::Concern

    # Override in classes that include this module
    def git_path() = Pathname.new('.')

    def git_url() = ''

    def src_path() = nil

    # When included in, e.g. an Image can call Image#git.branch for inclusion in docker image tag, etc
    def git
      inside_git_path do
        unless system('git rev-parse --git-dir > /dev/null 2>&1')
          return OpenStruct.new(sha: '', branch: '', tag: '', remotes: {})
        end

        OpenStruct.new(
          branch: `git rev-parse --abbrev-ref HEAD`.strip.gsub(/[^A-Za-z0-9-]/, '-'),
          sha: `git rev-parse --short HEAD`.chomp,
          tag: `git tag --points-at HEAD`.chomp,
          remotes: git_remote
        )
      end
    end

    def git_remote
      remote = `git remote -v`
      remote.split("\n").map { |e| e.split("\t") }.each_with_object({}) do |ary, hash|
        name = ary.first
        hash[name] ||= {}
        url, action = ary.last.split
        hash[name][action.delete('()')] = url
      end
    end

    def git_clone
      return if src_path.nil? || git_path.exist?

      src_path.mkpath unless src_path.exist?
      Dir.chdir(src_path) { git_clone_cmd.run }
    end

    def git_clone_cmd
      Command.new(
        # opts: context.options,
        # env: { this: 'that' },
        exec: "git clone #{url}"
        # opts: { printer: :null }
        # opts: context.options.merge(printer: :null)
      )
    end

    def git_url? = git_url.match(git_url_regex)

    # rubocop:disable Layout/LineLength
    def git_url_regex
      %r{^(([A-Za-z0-9]+@|http(|s)://)|(http(|s)://[A-Za-z0-9]+@))([A-Za-z0-9.]+(:\d+)?)(?::|/)([\d/\w.-]+?)(\.git){1}$}i
    end
    # rubocop:enable Layout/LineLength

    # TODO: Below methods lifted from namespaces/deploy_controller; Needs to be refactored
    # OR removed if not going to be used
    def git_deploy_tag
      new_tag = "#{git_api_tag_name}.v#{(git_versions.shift || 0) + 1}"
      output.puts new_tag
      # retag local
      # command.run("git tag -a -m #{new_tag} #{new_tag}")
      # push tag
      # command.run("git push origin #{new_tag}")
    end

    def git_versions
      git_all_tags.each_with_object([]) { |tag, versions| versions.push(tag[/\d+$/].to_i) }.sort.reverse
    end

    def git_all_tags() = (git_tags.local + git_tags.remote).grep(/#{git_api_tag_name}\.v\d+$/i)

    # TODO: Refactor
    def git_api_tag_name() = "#{target.application.deploy_tag}#{args.namespace_name}"

    def git_tags
      inside_git_path do
        @git_tags ||= OpenStruct.new(
          local: `git tag`.split,
          remote: `git ls-remote --tags`.split("\n").map { |tag| tag.split("\t").last.gsub('refs/tags/', '') }
        )
      end
    end

    def inside_git_path(&block)
      git_path.exist? ? Dir.chdir(git_path, &block) : OpenStruct.new
    end
  end
end
