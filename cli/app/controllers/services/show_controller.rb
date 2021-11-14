# frozen_string_literal: true

module Services
  class ShowController
    include ServicesHelper

    # rubocop:disable Metrics/AbcSize
    def execute
      modifier = options.modifier || '.yml'
      ary = context.filtered_services.each_with_object([]) do |service, ary|
        show_file = context.path(to: :manifests).join("#{service.name}#{modifier}")
        ary.append(show_file) if show_file.exist?
      end

      if ary.empty?
        Cnfs.logger.warn 'No files found'
        return
      end

      ary.each do |show_file|
        puts("- #{show_file}:\n")
        puts(File.read(show_file))
        puts "\n"
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
