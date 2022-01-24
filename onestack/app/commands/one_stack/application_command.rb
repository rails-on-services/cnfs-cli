# frozen_string_literal: true

module OneStack
  class ApplicationCommand < Hendrix::ApplicationCommand
    class << self
      def shared_options
        super.merge(
          clean: { desc: 'Clean component cache', type: :boolean },
          clean_all: { desc: 'Clean project cache', type: :boolean },
          fail_fast: { desc: 'Skip any remaining commands after a command fails', aliases: '--ff', type: :boolean },
          generate: { desc: 'Force generate manifest files ', aliases: '-g', type: :boolean },
          init: { desc: 'Initialize the project, e.g. download repositories and dependencies', type: :boolean },
          tags: { desc: 'Filter by tags', aliases: '--tags', type: :array }
        ).merge(seg_opts)
      end

      def seg_opts
        Hendrix.config.segments.dup.transform_values! do |opt|
          { desc: opt[:desc], aliases: opt[:aliases], type: :string }
        end
      end
    end
      
    # Load modules to add options, actions and sub-commands to existing command structure
    # TODO: If this is included in H:AppCommand then will it just work?
    # For that matter since it is here will it just work in a subclass of this class?
    include Hendrix::Extendable
  end
end
