# frozen_string_literal: true

module OneStack
  module ApplicationControllerConcern
    extend ActiveSupport::Concern

    def context() = @context ||= Component.context_from(options)

    # TODO: When moving queue to Hendrix then move this
    def queue() = @queue ||= CommandQueue.new # (halt_on_failure: true)

    #
    # Invokes init method on any model class that has defined it
    #
    def init
      # TODO: Remove this when models are fully loaded
      return unless options.init

      OneStack.config.asset_names.each do |asset|
        klass = asset.classify.constantize
        klass.init(context) if klass.respond_to?(:init)
      end
    end
  end
end
