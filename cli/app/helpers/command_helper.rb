# frozen_string_literal: true

module CommandHelper
  extend ActiveSupport::Concern
  include CnfsCommandHelper

  included do
    extend CnfsCommandHelper

    Project.first.command_options.each do |hash|
      add_cnfs_option(hash.delete(:name), hash)
    end

    add_cnfs_option :tags,              desc: 'Filter by tags',
                                        aliases: '--tags', type: :array
    add_cnfs_option :fail_fast,         desc: 'Skip any remaining commands after a command fails',
                                        aliases: '--ff', type: :boolean

    private

    # Configure the context with cli options and create the component tree
    def initialize_project
      # binding.pry
      Context.first.update(options: options)
      Context.first.set_component
      Context.first.set_assets
      # TODO: What about tags?
      # @options.merge!('tags' => Hash[*options.tags.flatten]) if options.tags
    end
  end
end
