# frozen_string_literal: true

module Primary
  class ShowController < ApplicationController
    cattr_reader :command_group, default: :service_manifest

    # TODO: move next two methods
    def update_context
      return unless context.deployment

      context.application = context.deployment.application
      context.namespace = context.deployment.namespace
      context.targets = context.namespace&.targets || []
      context.services = context.application.services unless context.services&.any?
    end

    def validate
      context.errors.add(:deployment, 'Invalid') unless context.deployment.present?
    end

    def execute
      each_target do
        execute_on_target
      end
    end

    def execute_on_target
      context.services.map(&:name).each do |service_name|
        file_name = options.modifier ? "#{service_name}#{options.modifier}" : "#{service_name}.yml"
        show_file = context.write_path.join(file_name)
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
