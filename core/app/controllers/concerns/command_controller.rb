# frozen_string_literal: true

module Concerns
  module CommandController
    extend ActiveSupport::Concern
    include Cnfs::Concerns::CommandController

    included do
      extend Cnfs::Concerns::CommandController

      # Load options for configured segments
      Cnfs.config.command_options.each { |name, values| add_cnfs_option(name, values) }

      add_cnfs_option :clean,             desc: 'Clean component cache',
        type: :boolean
      add_cnfs_option :clean_all,         desc: 'Clean project cache',
        type: :boolean
      add_cnfs_option :fail_fast,         desc: 'Skip any remaining commands after a command fails',
        aliases: '--ff', type: :boolean
      add_cnfs_option :generate,          desc: 'Force generate manifest files ',
        aliases: '-g', type: :boolean
      add_cnfs_option :init,              desc: 'Initialize the project, e.g. download repositories and dependencies',
        type: :boolean
      add_cnfs_option :tags,              desc: 'Filter by tags',
        aliases: '--tags', type: :array

      # Load modules to add options, actions and sub-commands to existing command structure
      include Concerns::Extendable
    end
  end
end
