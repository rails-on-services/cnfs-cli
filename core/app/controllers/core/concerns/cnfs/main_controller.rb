# frozen_string_literal: true

module Core
  class CreateController < Thor; include ::Concerns::CrudController end

  class ListController < Thor; include ::Concerns::CrudController end

  class ShowController < Thor; include ::Concerns::CrudController end

  class EditController < Thor; include ::Concerns::CrudController end

  class DestroyController < Thor; include ::Concerns::CrudController end

  module Concerns
    module Cnfs
      module MainController
        extend ActiveSupport::Concern

        included do
          include ::Concerns::CommandController

          cnfs_class_options :dry_run

          # CRUD Actions
          %w[create show edit destroy list].each do |action|
            klass = "core/#{action}_controller".classify.constantize
            register klass, action, "#{action} [ASSET] [options]", "#{action.capitalize} asset"
          end

          # Builder operates on Images
          register Images::CommandController, 'image', 'image [SUBCOMMAND] [options]', 'Manage images'

          # Provisioner operates on Plans
          register Plans::CommandController, 'plan', 'plan SUBCOMMAND [options]', 'Manage infrastructure plans'

          register Projects::CommandController, 'project', 'project SUBCOMMAND [options]', 'Manage project'

          register Resources::CommandController, 'resource', 'resource [SUBCOMMAND]', 'Manage component resources'

          register Segments::CommandController, 'segment', 'segment [SUBCOMMAND]', 'Manage segments'

          # Runtime operates on Services
          register Services::CommandController, 'service', 'service SUBCOMMAND [options]', 'Manage services'

          # register Repositories::CommandController, 'repository', 'repository SUBCOMMAND [options]',
          # 'Add, create, list and remove project repositories'
        end
      end
    end
  end
end
