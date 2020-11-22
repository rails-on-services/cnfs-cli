# frozen_string_literal: true

module Services
  class ShowController
    include ServicesHelper
    attr_accessor :services

    # rubocop:disable Metrics/AbcSize
    def execute
      modifier = options.modifier || '.yml'
      services.each do |service|
        show_file = service.write_path.join("#{service.name}#{modifier}")
        unless File.exist?(show_file)
          puts "File not found: #{show_file}"
          next
        end

        puts(File.read(show_file))
        puts("\nContents from: #{show_file}")
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
