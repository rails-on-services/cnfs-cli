# frozen_string_literal: true

module Services
  class ShowController < ApplicationController
    def execute
      application.arguments.services.each do |service_name|
        modifier = options.modifier || '.yml'
        show_file = application.write_path.join("#{service_name}#{modifier}")
        unless File.exist?(show_file)
          response.output.puts "File not found: #{show_file}"
          next
        end
        response.output.puts(File.read(show_file))
        response.output.puts("\nContents from: #{show_file}")
      end
    end
  end
end
