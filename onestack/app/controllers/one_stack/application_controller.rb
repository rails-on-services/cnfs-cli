# frozen_string_literal: true

module OneStack
  class ApplicationController < Hendrix::ApplicationController
    def context() = @context ||= Component.context_from(options)

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
