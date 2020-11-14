# frozen_string_literal: true

# Creates a new CNFS Rails repository
# 1. Copy files into the root of the repository
# 2. Invoke 'rails plugin new' to create the repository's core gem (a template is invoked to modify generated files)
# 3. Invoke 'bundle gem' to create the repository's SDK gem (no template so all modifications are made in this file)
module Aws
  class BlueprintGenerator < Thor::Group
    include Thor::Actions

    def hello
      binding.pry
    end
  end
end
