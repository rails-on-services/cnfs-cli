# frozen_string_literal: true

module Concerns
  module BuilderRuntime
    extend ActiveSupport::Concern

    included do
      # include Concerns::BelongsToProject
      include TtyHelper

      attr_accessor :queue

      has_many :environments
    end

    # method inherited from A/R base interferes with controller#destroy
    # undef_method :destroy
    def destroy; end

    def supported_commands
      raise NotImplementedError, 'To implement: returns an array of command names supported by this runtime'
    end

    # Sub-classes, e.g. compose, skaffold override to implement, e.g. switch!
    def prepare
      raise NotImplementedError, 'this needs to be done'
    end

    # Simplified syntax to return a command array
    def rv(command_string)
      tool_check
      [command_env, command_string, command_options]
    end

    def command_env
      @command_env ||= {}
    end

    # options returned to the TTY command
    def command_options
      opts = {}
      opts.merge!(pty: true) if 1 == 2
      # binding.pry
      opts.merge!(only_output_on_error: true) if project.options.quiet
      opts
    end

    def tool_check
      missing_tools = required_tools - Cnfs.capabilities
      raise Cnfs::Error, "Missing #{missing_tools}" if missing_tools.any?

      true
    end

    def required_tools
      []
    end

    # Utility methods
    def generate
      generator.invoke_all
    end

    def generator
      generator_class.new([project], options)
    end

    def generator_class
      "#{self.class.name}Generator".safe_constantize
    end

    def path(from: nil, to: :templates, absolute: false)
      project.path(from: from, to: to, absolute: absolute)
    end

    def project_name
      project.name
    end

    # class_methods do
    #   def dirs
    #     [Cnfs.gem_root.join('config').to_s]
    #   end
    # end
  end
end
