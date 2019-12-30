# frozen_string_literal: true

module App::Backend
  class DeployController < Cnfs::Command
    def execute
      each_target do |target|
        before_execute_on_target
        execute_on_target
      end
      each_target do |target|
        call(:status)
      end
    end

    def execute_on_target
      # command(command_options).run!(target.runtime.deploy(services), cmd_options)
      runtime.deploy(request)
    end

    def uat_or_cluster
      # prefix = Settings.components.be.components.application.config.deploy_tag
      prefix = 'enable-api.'
      api_tag_name = "#{prefix}#{tag_name}"
      existing_local_tags = %x(git tag).split
      existing_remote_tags = %x(git ls-remote --tags).split("\n").map { |tag_string| tag_string.split("\t").last.gsub('refs/tags/', '') }
      versions = []
      (existing_local_tags + existing_remote_tags).select { |tag| tag.match?(/#{api_tag_name}\.[v]\d+$/i) }.each do |tag|
        # push numeric version suffix into versions array
        versions.push(tag[/\d+$/].to_i)
      end
      versions.sort!.reverse!
      # bump version
      version = "v#{versions[0].to_i + 1}"
      # retag local
      %x(git tag -a -m #{api_tag_name}.#{version} #{api_tag_name}.#{version})
      # push tag
      %x(git push origin #{api_tag_name}.#{version})
    end
  end
end
