# frozen_string_literal: true

module Hendrix
  class ProjectGenerator < ApplicationGenerator
    argument :name
    argument :gem_name_root

    private

    # Used by Plugin and Application
    def app_structure
      to_render.each do |template|
        destination = template.relative_path_from(templates_path).to_s.delete_suffix('.erb')
        template(template, destination)
      end
    end

    def to_render() = (templates - manual_templates.map{ |path| templates_path.join(path) })

    def manual_templates() = []
  end
end
=begin
    # def component_files() = _component_files
      # keep('config/initializers')

    def _component_files
      binding.pry
      # keep("app/controllers/#{name}/concerns")
      # keep("app/controllers/#{name}/concerns")
      # keep("app/generators/#{name}/concerns")
      # keep("app/models/#{name}/concerns")
      # keep("app/views/#{name}/concerns")
      keep('config/initializers')
    end

    # def keep(keep_path) = create_file(path.join(keep_path, '.keep'))
=end
