# frozen_string_literal: true

module CommandHelper
  extend ActiveSupport::Concern
  include CnfsCommandHelper

  included do
    extend CnfsCommandHelper

    attr_accessor :context

    if CnfsCli.config.load_nodes
      CnfsCli.configuration.command_options.each do |hash|
        add_cnfs_option(hash[:name], hash.except(:name))
      end
    end

    add_cnfs_option :tags,              desc: 'Filter by tags',
                                        aliases: '--tags', type: :array
    add_cnfs_option :fail_fast,         desc: 'Skip any remaining commands after a command fails',
                                        aliases: '--ff', type: :boolean

    private

    # Override base controller and just provide the context to exec controllers
    def controller_args
      { context: context }
    end

    # Configure the context with cli options and create the component tree
    def context
      @context ||= Context.create(root: project, options: options, args: args)
    end

    def project
      @project ||= Project.first
    end
  end
end
