# frozen_string_literal: true

module Services
  class ShowController
    include ServicesHelper
    attr_accessor :services

    # rubocop:disable Metrics/AbcSize
    # TODO: FIX: When invalid service name is requested it is silently ignored
    def execute
      modifier = options.modifier || '.yml'
      services.each do |service|
        show_file = service.write_path.join("#{service.name}#{modifier}")
        unless show_file.exist?
          Cnfs.logger.warn "File not found: #{show_file}"
          next
        end

        puts(File.read(show_file))
        puts("\nContent from: #{show_file}\n")
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
