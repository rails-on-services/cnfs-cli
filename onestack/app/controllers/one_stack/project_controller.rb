# frozen_string_literal: true

module OneStack
  class ProjectController < SolidApp::ApplicationController # Hendrix::ProjectController
    def new
      binding.pry
      super
    end

    def new_application
      super

      # Dir.chdir(path) { generator(:extension).invoke(:segments) }

      # Dir.chdir(path) do
      #   Hendrix.loaders['framework'].unload
      #   load 'cnfs/boot_loader.rb'
      #   SegmentRoot.first.generate_key
      # end

      return unless options.guided

      # Start a view here
      # TODO: This should create a node which should create a file with the yaml or a directory
      # Project.new(name: context.args.name).create
    end
  end
end
