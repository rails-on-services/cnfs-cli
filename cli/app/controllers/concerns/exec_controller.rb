# frozen_string_literal: true

module Concerns
  module ExecController
    extend ActiveSupport::Concern
    include Cnfs::Concerns::ExecController

    included do
      extend Cnfs::Concerns::ExecController

      attr_accessor :context

      # Load modules to add options, actions and sub-commands to existing command structure
      include Concerns::Extendable
    end

    # TODO: When moving queue to cnfs_core then move this
    def queue() = @queue ||= CommandQueue.new # (halt_on_failure: true)

    #
    # Invokes init method on any model class that has defined it
    #
    def init
      return unless context.options.init

      CnfsCli.asset_names.each do |asset|
        klass = asset.classify.constantize
        klass.init(context) if klass.respond_to?(:init)
      end
    end

    # TODO: Lifted from a deprecated helper. Is it helpful?
    def raise_if_runtimes_empty
      return if context.resource_provisioners.any?

      raise Cnfs::Error, "Services not found: #{context.args.resource || context.args.resources.join(' ')}"
    end

    def raise_if_runtimes_empty
      return if context.runtimes.any?

      raise Cnfs::Error, "Services not found: #{context.args.service || context.args.services.join(' ')}"
    end
  end
end
