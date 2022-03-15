# frozen_string_literal: true

module OneStack
  # class CreateController < Thor; include OneStack::Concerns::CrudController end

  # class ListController < Thor; include OneStack::Concerns::CrudController end

  # class ShowController < Thor; include OneStack::Concerns::CrudController end

  # class EditController < Thor; include OneStack::Concerns::CrudController end

  # class DestroyController < Thor; include OneStack::Concerns::CrudController end

  class MainCommand < ApplicationCommand
    has_class_options :dry_run
    has_class_options OneStack.config.segments.keys

    # CRUD Actions
    # %w[create show edit destroy list].each do |action|
    #   klass = "core/#{action}_controller".classify.constantize
    #   register klass, action, "#{action} [ASSET] [options]", "#{action.capitalize} asset"
    # end

    # Builder operates on Images
    register OneStack::ImagesCommand, 'image', 'image [SUBCOMMAND] [options]', 'Manage images'

    # Provisioner operates on Plans
    register OneStack::PlansCommand, 'plan', 'plan SUBCOMMAND [options]', 'Manage infrastructure plans'

    register OneStack::ResourcesCommand, 'resource', 'resource [SUBCOMMAND]', 'Manage component resources'

    register OneStack::SegmentsCommand, 'segment', 'segment [SUBCOMMAND]', 'Manage segments'

    # Runtime operates on Services
    register OneStack::ServicesCommand, 'service', 'service SUBCOMMAND [options]', 'Manage services'

    # register OneStack::RepositoriesCommand, 'repository', 'repository SUBCOMMAND [options]',
    # 'Add, create, list and remove project repositories'

    desc 'tree', 'Display a tree'
    def tree
      # TODO: @options are not being passed in from command line
      context = Navigator.new(options: @options, args: @args, path: APP_CWD).context
      require 'tty-tree'
      puts '', TTY::Tree.new(context.as_tree).render
    end

    desc 'generate', 'generate'
    def generate(type, *attributes) = execute

    desc 'console', 'Start a console (short-cut: c)'
    def console(name = nil, *values)
      hash = { method: :execute } # Specify the method :execute to avoid method_missing being invoked on 'console'
      name = name.pluralize if values.size > 1
      hash.merge!(name.to_sym => values) if name # filter the context asset specified in 'name' by values
      hash.merge!(controller: :console, namespace: :one_stack)
      # binding.pry
      execute(**hash)
    end
  end
end
