# frozen_string_literal: true

module Concerns
  module PlatformRunner
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
      # include ActiveModel::AttributeAssignment

      attr_accessor :context

      define_model_callbacks :execute
    end

    # def initialize(**kwargs)
    #   assign_attributes(**kwargs)
    # end

    def platform
      @platform ||= Platform.new
    end

    # The classes including this concern are the ones that interface w/ the OS
    # serialize :dependencies, Array
    def dependencies
      # TODO: Implement
    end

    def queue
      @queue ||= CommandQueue.new
    end

    # method inherited from A/R base interferes with controller#destroy
    # undef_method :destroy
    def destroy; end

    def supported_commands
      raise NotImplementedError, 'To implement: returns an array of command names supported by this runtime'
    end

    # Check if the manifest is outdated and generate it if necessary
    def generate(force: false)
      # TODO: enable return
      # return if already_generated unless force
      manifest = context.manifest
      manifest.purge! if context.options.generate
      return if manifest.valid?

      manifest.purge!

      # TODO: why not set detination root? if a good reason then note it here
      # g.destination_root = manifest.write_path
      generator.invoke_all
      Cnfs.logger.warn("Invalid manifest: #{manifest.errors.full_messages}") unless manifest.valid?
    end

    def generator
      generator_class.new([self, context])
    end

    def generator_class
      "#{self.class.name}Generator".safe_constantize
    end

    def path(from: nil, to: :templates, absolute: false)
      context.path(from: from, to: to, absolute: absolute)
    end
  end
end
