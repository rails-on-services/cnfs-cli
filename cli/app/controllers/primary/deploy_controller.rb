# frozen_string_literal: true

module Primary
  class DeployController < ApplicationController
    def execute
      each_target do |target|
        # before_execute_on_target
        execute_on_target
      end
      # each_target do |target|
      #   call(:status)
      # end
    end

    def execute_on_target
      if options.local
        runtime.deploy.run!
        return
      end

      deploy_git_tag
    end

    def deploy_git_tag
      prefix = 'enable-api.'
      api_tag_name = "#{prefix}#{args.namespace_name}"
      Dir.chdir('..') do
      versions = tags(api_tag_name)
      new_tag = "#{api_tag_name}.v#{versions.shift + 1}"
      output.puts new_tag
      end
      # retag local
      # command.run("git tag -a -m #{new_tag} #{new_tag}")
      # push tag
      # command.run("git push origin #{new_tag}")
    end

    def tags(api_tag_name)
      all_tags = (local_tags + remote_tags).select { |tag| tag.match?(/#{api_tag_name}\.[v]\d+$/i) }
      # push numeric version suffix into array
      all_tags.each_with_object([]) { |tag, versions| versions.push(tag[/\d+$/].to_i) }.sort.reverse
    end

    def local_tags; %x(git tag).split end

    def remote_tags
      %x(git ls-remote --tags).split("\n").map { |tag| tag.split("\t").last.gsub('refs/tags/', '') }
    end
  end
end
