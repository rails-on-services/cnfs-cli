# frozen_string_literal: true

module CommandHelper
  extend ActiveSupport::Concern
  include CnfsCommandHelper

  included do
    extend CnfsCommandHelper
    add_cnfs_option :environment,       desc: 'Target environment',
                                        aliases: '-e', type: :string, default: Cnfs.config.environment
    add_cnfs_option :namespace,         desc: 'Target namespace',
                                        aliases: '-n', type: :string, default: Cnfs.config.namespace
    add_cnfs_option :repository,        desc: 'The repository in which to run the command',
                                        aliases: '-r', type: :string, default: Cnfs.config.repository
    add_cnfs_option :source_repository, desc: 'The source repository to link to',
                                        aliases: '-s', type: :string, default: Cnfs.config.source_repository

    add_cnfs_option :tags,              desc: 'Filter by tags',
                                        aliases: '-t', type: :array
    add_cnfs_option :fail_fast,         desc: 'Skip any remaining commands after a command fails',
                                        aliases: '--ff', type: :boolean
  end
end
