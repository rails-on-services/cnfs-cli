# frozen_string_literal: true

module Infra
  class AddController < Thor
    include CommandHelper

    # Activate common options
    cnfs_class_options :environment
    # binding.pry
    class_option :namespace, desc: 'Target namespace',
                             aliases: '-n', type: :string
    cnfs_class_options :dry_run, :logging

    private

    def execute
      # generator = Component::EnvironmentGenerator.new([arguments.name], options)
      # generator.behavior = options.behavior
      # generator.invoke_all
      # NOTE: The blueprint generator is in the core gem, but the content is in the infra gem
      binding.pry
    end
  end
end
