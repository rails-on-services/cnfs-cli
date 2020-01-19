# frozen_string_literal: true

module Primary
  class DeployController < ApplicationController
    def execute
      each_target do |target|
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      # User must specify local otherwise deployment is done via a git tag
      if options.local
        runtime.deploy.run!
        return
      end

      deploy_git_tag
    end

    def deploy_git_tag
      new_tag = "#{api_tag_name}.v#{versions.shift + 1}"
      output.puts new_tag
      # retag local
      # command.run("git tag -a -m #{new_tag} #{new_tag}")
      # push tag
      # command.run("git push origin #{new_tag}")
    end

    def versions; tags.each_with_object([]) { |tag, versions| versions.push(tag[/\d+$/].to_i) }.sort.reverse end

    def tags; (local_tags + remote_tags).select { |tag| tag.match?(/#{api_tag_name}\.[v]\d+$/i) } end

    def api_tag_name; "#{target.application.deploy_tag}#{args.namespace_name}" end

    def local_tags; %x(git tag).split end

    def remote_tags
      %x(git ls-remote --tags).split("\n").map { |tag| tag.split("\t").last.gsub('refs/tags/', '') }
    end
  end
end
