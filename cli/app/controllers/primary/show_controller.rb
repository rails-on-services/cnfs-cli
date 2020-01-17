# frozen_string_literal: true

module Primary
  class ShowController < ApplicationController
    def execute
      each_target do
        execute_on_target
      end
    end

    def execute_on_target
      args.service_names.each do |service_name|
        file_name = options.modifier ? "#{service_name}#{options.modifier}" : "#{service_name}.yml"
        show_file = target.write_path.join(file_name)
        if File.exist?(show_file)
          output.puts(File.read(show_file))
          output.puts("\nContents from: #{show_file}")
        else
          output.puts "File not found: #{show_file}"
        end
      end
    end
  end
end
