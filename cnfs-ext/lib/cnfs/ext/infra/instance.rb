# frozen_string_literal: true

module Cnfs::Core
  class Platform::Infra::Instance
    include Concerns::Resource

    class Generator < Thor::Group
      include Thor::Actions

      # TODO: Move this to be/infra/instance/compose.rb
      # and skaffold would go to be/infra/kubernetes/skaffold.rb
      # TODO: Look at Be CommonGenerator for a_path, etc
      def self.a_path; File.dirname(__FILE__) end

      # Compose only methods
      def write_compose_envs
        # return unless infra.cluster_type.eql?('instance')
        # TODO: Replace with Config::Option class and call to_env on it
        content = compose_environment.each_with_object([]) do |kv, ary|
          ary << "#{kv[0].upcase}=#{kv[1]}"
        end.join("\n")
        content = "# This file was auto generated\n# The values are used by docker-compose\n# #{Ros.env}\n#{content}"
        # empty_directory(Ros::Generators::Stack.compose_dir)
        create_file(application.compose_file, "#{content}\n")
      end

      private

      # continue compose only methods
      def compose_environment
        ext_info = OpenStruct.new
        if (RbConfig::CONFIG['host_os'] =~ /linux/ and Etc.getlogin)
          shell_info = Etc.getpwnam(Etc.getlogin)
          ext_info.puid = shell_info.uid
          ext_info.pgid = shell_info.gid
        end
        {
          compose_file: Dir["#{application.deploy_path}/**/*.yml"].map{ |p| p.gsub("#{Ros.root}/", '') }.sort.join(':'),
          compose_project_name: application.compose_project_name,
          context_dir: relative_path,
          ros_context_dir: "#{relative_path}/ros",
          image_repository: Stack.config.platform.config.image_registry,
          image_tag: Stack.image_tag
        }.merge(ext_info.to_h)
      end
    end
  end
end
