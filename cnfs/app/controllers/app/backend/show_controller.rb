# frozen_string_literal: true

module App::Backend
  class ShowController < Cnfs::Command
    def execute
      with_selected_target do
        before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      unless service and show_file
        output.puts "Request not found: #{request.last_service_name}"
        return
      end
      output.puts(File.read(show_file))
      output.puts("\nContents from: #{show_file}")
    end

    def show_file
      @show_file ||= (
        %w[application target].each do |dir|
          path = target.write_path.join(dir).join(service.layer.name).join(file_name).to_s
          return path if File.exist?(path)
        end
      )
    end

    def file_name; options.modifier ? "#{service_name}#{options.modifier}" : "#{service_name}.yml" end

    def service_name; service.name end

    def service; request.services.first end
  end
end
