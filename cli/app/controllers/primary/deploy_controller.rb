# frozen_string_literal: true

module Primary
  class DeployController < ApplicationController
    def execute
      each_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      return unless valid_action?(:deploy) && valid_namespace?

      # Local deploy is a deployment direct to the cluster from the local machine
      # The default is to push a tag to the repo which triggers a deploy via CI/CD
      if options.local
        runtime.deploy # .run!
      else
        deploy_git_tag
      end
    end

    def deploy_git_tag
      new_tag = "#{api_tag_name}.v#{(versions.shift || 0) + 1}"
      output.puts new_tag
      # retag local
      # command.run("git tag -a -m #{new_tag} #{new_tag}")
      # push tag
      # command.run("git push origin #{new_tag}")
    end

    def versions
      tags.each_with_object([]) { |tag, versions| versions.push(tag[/\d+$/].to_i) }.sort.reverse
    end

    def tags
      (local_tags + remote_tags).select { |tag| tag.match?(/#{api_tag_name}\.[v]\d+$/i) }
    end

    def api_tag_name
      "#{target.application.deploy_tag}#{args.namespace_name}"
    end

    def local_tags
      `git tag`.split
    end

    def remote_tags
      `git ls-remote --tags`.split("\n").map { |tag| tag.split("\t").last.gsub('refs/tags/', '') }
    end
  end
end
