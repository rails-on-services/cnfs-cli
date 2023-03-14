# frozen_string_literal: true

module OneStack
  class Project::ExtensionGenerator < ApplicationGenerator
  # class Project::ExtensionGenerator < Hendrix::Project::ExtensionGenerator
    def segments
      binding.pry
      templates.each do |template|
        destination = template.relative_path_from(templates_path).to_s.delete_suffix('.erb')
        template(template, destination)
        gsub_file(destination, /^#./, '') if options.config && destination.end_with?('.yml')
      end
      # TODO: Restore after bug in Node is fixed
      # keep('segments')
    end

    private

    def source_paths() = super

    def internal_path() = Pathname.new(__dir__)
  end
end
