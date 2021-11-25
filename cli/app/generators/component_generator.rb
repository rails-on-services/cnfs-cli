# frozen_string_literal: true

class ComponentGenerator < NewGenerator
  def component_file
    create_file('component.yml')
  end
end
