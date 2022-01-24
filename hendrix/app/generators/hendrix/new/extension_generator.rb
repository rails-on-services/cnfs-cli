# frozen_string_literal: true

module Hendrix
  class New::ExtensionGenerator < NewGenerator
    def segments
      templates.each do |template|
        destination = template.relative_path_from(templates_path).to_s.delete_suffix('.erb')
        template(template, destination)
        gsub_file(destination, /^#./, '') if options.config && destination.end_with?('.yml')
      end
      # TODO: Restore after bug in Node is fixed
      # keep('segments')
    end

    private

    def internal_path() = Pathname.new(__dir__)
  end
end
