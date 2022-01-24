# frozen_string_literal: true

module OneStack
  # class CreateController < Thor; include OneStack::Concerns::CrudController end

  # class ListController < Thor; include OneStack::Concerns::CrudController end

  # class ShowController < Thor; include OneStack::Concerns::CrudController end

  # class EditController < Thor; include OneStack::Concerns::CrudController end

  # class DestroyController < Thor; include OneStack::Concerns::CrudController end

  class MainCommand < ApplicationCommand
    has_class_options :dry_run
    has_class_options Hendrix.config.segments.keys

    # CRUD Actions
    # %w[create show edit destroy list].each do |action|
    #   klass = "core/#{action}_controller".classify.constantize
    #   register klass, action, "#{action} [ASSET] [options]", "#{action.capitalize} asset"
    # end

    # Builder operates on Images
    register OneStack::ImagesCommand, 'image', 'image [SUBCOMMAND] [options]', 'Manage images'

    # Provisioner operates on Plans
    register OneStack::PlansCommand, 'plan', 'plan SUBCOMMAND [options]', 'Manage infrastructure plans'

    register OneStack::ProjectsCommand, 'project', 'project SUBCOMMAND [options]', 'Manage project'

    register OneStack::ResourcesCommand, 'resource', 'resource [SUBCOMMAND]', 'Manage component resources'

    register OneStack::SegmentsCommand, 'segment', 'segment [SUBCOMMAND]', 'Manage segments'

    # Runtime operates on Services
    register OneStack::ServicesCommand, 'service', 'service SUBCOMMAND [options]', 'Manage services'

    # register OneStack::RepositoriesCommand, 'repository', 'repository SUBCOMMAND [options]',
    # 'Add, create, list and remove project repositories'

    desc 'tree', 'Display a tree'
    def tree
      # TODO: @options are not being passed in from command line
      context = Component.context_from(@options)
      require 'tty-tree'
      puts '', TTY::Tree.new(context.as_tree).render
    end
  end
end
