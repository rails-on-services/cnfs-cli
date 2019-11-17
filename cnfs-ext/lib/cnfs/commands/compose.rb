# frozen_string_literal: true

module Cnfs::Commands
  module Compose
    def self.included(base)
      base.before_execute :switch!
    end

    def switch!
      Dir.chdir(config.platform.root) do
        FileUtils.rm_f('.env')
        FileUtils.ln_s(config.platform.path_for(:runtime).join('compose/compose.env').to_s, '.env')
      end
      Dir.chdir("#{config.platform.root}/services") do
        FileUtils.rm_f('.env')
        FileUtils.ln_s("../#{config.platform.path_for}/application/backend", '.env')
      end
      unless config.platform.is_cnfs?
        Dir.chdir("#{config.platform.root}/ros/services") do
          FileUtils.rm_f('.env')
          FileUtils.ln_s("../../#{config.platform.path_for}/application/backend", '.env')
        end
      end
    end

    # def application_compose_project_name; 'whistler_mounted' end
    def compose_project_name
      # binding.pry
      "#{config.platform.config.name}_#{config.platform.env}"
    end

    def compose_file; @compose_file ||= "#{compose_dir}/compose.env" end
    def compose_dir; "#{config.platform.path_for(:runtime)}/compose" end

    # See: https://docs.docker.com/engine/reference/commandline/ps
    def services(format: '{{.Names}}', status: :running, **filters)
      @services ||= list_services(format: format, status: status, **filters)
    end

    def list_services(format:, status:, **filters)
      filter = filters.each_pair.map { |key, value| "--filter 'label=#{key}=#{value}'" }
      # filters.append("--filter 'label=stack.name=#{Settings.config.name}'")
      # filters.append("--filter 'label=application.component=#{application_component}'")
      # filters.append("--filter 'label=platform.feature_set=#{application.current_feature_set}'")
      filter.append("--filter 'status=#{status}'") if status
      filter.append("--format '#{format}'") if format

      cmd = "docker ps #{filter.join(' ')}"
      output.puts cmd if options.verbose
      out, err = command(printer: :null).run(cmd)

      # TODO: _server is only one profile; fix
      # TODO: _1 is assumed; there could be > 1
      out.split("\n").map{ |a| a.gsub("#{compose_project_name}_", '').chomp('_1') }
    end

    def requested_services; params[:services] end

    def compose(service, command)
      cmd = ['docker-compose']
      cmd << (services.include?(service) ? 'exec' : 'run --rm')
      cmd.append(service).append(command)
      output.puts(cmd.join(' ')) if options.verbose
      # cmd = TTY::Command.new(pty: true).run(cmd.join(' '))
      system(cmd.join(' '))
    end
  end
end
