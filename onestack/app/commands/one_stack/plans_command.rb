# frozen_string_literal: true

module OneStack
  class PlansCommand < ApplicationCommand
    has_class_options :dry_run, :generate # , :logging
    has_class_options Hendrix.config.segments.keys

    # TODO: If these options stay they need to move to a Terrform::Concerns::PlanController
    # option :clean, desc: 'Clean local modules cache. Force to download latest modules from TF registry',
    #                type: :boolean
    # option :init, desc: 'Force to download latest modules from TF registry',
    #               type: :boolean
    has_options :force
    desc 'deploy', 'Deploy all resources for the specified segment'
    def deploy() = execute

    has_options :force
    desc 'undeploy', 'Destroy all resources for the specified segment'
    def undeploy
      validate_destroy("\n#{'WARNING!!!  ' * 5}\nAbout to *permanently destroy* #{context.component.name} " \
                       "in #{context.component.owner&.name}\nDestroy cannot be undone!\n\nAre you sure?")
      execute
    end
  end
end
