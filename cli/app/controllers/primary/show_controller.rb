# frozen_string_literal: true

module Primary
  class ShowController < ApplicationController
    def execute
      each_target do
        # before_execute_on_target
        execute_on_target
      end
    end

    def execute_on_target
      if request.services.empty?
        output.puts 'Configuration not found'
        return
      end

      request.services.each do |service|
        file_name = options.modifier ? "#{service.name}#{options.modifier}" : "#{service.name}.yml"
        show_file = target.write_path.join(file_name) # .to_s
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
