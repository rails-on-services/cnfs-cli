# frozen_string_literal: true

module OneStack
  class ApplicationController < SolidSupport::ApplicationController
    def context() = nav.context

    def nav() = Navigator.current || Navigator.new(path: APP_CWD, options: options, args: args)

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
