# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Ps < Cnfs::Command
    module Compose

      def self.included(base)
        base.on_execute :run_compose
      end

      def run_compose
        out, err = command(printer: :null).run('docker-compose ps')
        @result = out.split("\n")[2..].map { |line| line.split[0] }
        @result.map! { |a| a.gsub("#{application_compose_project_name}_", '').chomp('_1') }
        @display = "#{result.join("\n")}"
      end

      def application_compose_project_name; 'whistler_mounted' end

        def services(status: nil, application_component: nil)
          status ||= 'running'
          filters = []
          filters.append("--filter 'status=#{status}'")
          # filters.append("--filter 'label=stack.name=#{Settings.config.name}'")
          # filters.append("--filter 'label=application.component=#{application_component}'") if application_component
          # filters.append("--filter 'label=platform.feature_set=#{application.current_feature_set}'")
          filters.append("--format '{{.Names}}'")
          out, err = command(printer: :null).run("docker ps #{filters.join(' ')}")
          # return [] if options.n
          # TODO: _server is only one profile; fix
          # TODO: _1 is assumed; there could be > 1

          out.split("\n").map{ |a| a.gsub("#{application_compose_project_name}_", '').chomp('_1') }
        end
    end
  end
end
