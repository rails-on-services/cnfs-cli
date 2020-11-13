# frozen_string_literal: true

module Angular
  class RepositoryGenerator < Thor::Group
    include Thor::Actions
    argument :project_name
    argument :name

    def hello
      binding.pry
    end
  end
end
