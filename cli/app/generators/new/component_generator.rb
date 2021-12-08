# frozen_string_literal: true

class New::ComponentGenerator < NewGenerator
  def component_file
    create_file('component.yml')
  end

  private

  def internal_path() = Pathname.new(__dir__)
end
