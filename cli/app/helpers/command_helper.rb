# frozen_string_literal: true

module CommandHelper
  extend ActiveSupport::Concern
  include CnfsCommandHelper

  included do
    extend CnfsCommandHelper

    attr_accessor :context

    # Load options for configured segments
    if CnfsCli.config.project
      CnfsCli.config.command_options.each do |name, values|
        add_cnfs_option(name, values)
      end
    end

    add_cnfs_option :clean,             desc: 'Clean component cache',
                                        type: :boolean
    add_cnfs_option :init,              desc: 'Initialize the project, e.g. download repositories and dependencies',
                                        type: :boolean
    add_cnfs_option :fail_fast,         desc: 'Skip any remaining commands after a command fails',
                                        aliases: '--ff', type: :boolean
    add_cnfs_option :tags,              desc: 'Filter by tags',
                                        aliases: '--tags', type: :array

    # Load modules to add options, actions and sub-commands to existing command structure
    Cnfs.modules_for(mod: CnfsCli, klass: self).each { |mod| include mod }

    private

    # Override base controller and just provide the context to exec controllers
    def controller_args
      return { context: context } if CnfsCli.config.project

      { context: OpenStruct.new(options: options, args: args) }
    end

    # Configure the context with cli options and create the component tree
    def context
      Cnfs.with_timer('context') do
        @context ||= Context.create(root: project, options: options, args: args)
      end
      @context
    end

    def project
      @project ||= Project.first
    end
  end
end
