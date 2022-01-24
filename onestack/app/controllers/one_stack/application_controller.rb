# frozen_string_literal: true

module OneStack
  class ApplicationController < Hendrix::ApplicationController
    # extend ActiveSupport::Concern
    # include Cnfs::Concerns::ExecController

    # included do
      # extend Cnfs::Concerns::ExecController

      # Load modules to add options, actions and sub-commands to existing command structure
      include Hendrix::Extendable
    # end

    def context() = @context ||= Component.context_from(options)

    # TODO: When moving queue to cnfs_core then move this
    def queue() = @queue ||= CommandQueue.new # (halt_on_failure: true)

    #
    # Invokes init method on any model class that has defined it
    #
    def init
      return unless options.init

      Cnfs::Core.asset_names.each do |asset|
        klass = asset.classify.constantize
        klass.init(context) if klass.respond_to?(:init)
      end
    end
  end
end
