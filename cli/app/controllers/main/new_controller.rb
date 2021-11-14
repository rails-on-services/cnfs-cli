# frozen_string_literal: true

module Main
  class NewController
    include ExecHelper
    include TtyHelper

    def execute
      path = Pathname.new(args.name)
      path.rmtree if path.exist?
      path.mkdir
      # generator = ProjectGenerator.new([args.name], options)
      # generator.destination_root = args.name
      # generator.invoke_all

      Cnfs.data_store.setup
      CnfsCli.load_configurations(path: args.name, load_nodes: false)
      # CnfsCli.load_root_node
      # TODO: This should create a node which should create a file with the yaml or a directory
      # Component.first.components.create(name: 'holy')
      # pu = Project.first.users.create(name: :test)
      # pf = Project.first
      # view = ProjectsView.new(model: pf)
      # view.edit
      # pf.save if pf.changed
      # Project.first.edit
      Project.new(name: args.name).create
      # binding.pry

      # TODO: Start a view here
      # return unless options.guided

      # prompt.say('Starting guided project configuration')
      # require 'pry'
      # m = Project.new
      # m.name = 'testing'
      # m.save
      # Cnfs.require_deps
      # end
    end
  end
end
