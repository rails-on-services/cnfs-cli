# frozen_string_literal: true

module Namespaces
  class CrudController
    include ExecHelper

    def update
      return unless (env = Environment.find_by(name: options.environment))

      return unless (ns = Namespace.find_by(environment: env, name: args.name))

      result = BaseView.new.render(ns)
      ns.update(result)
    end

    def add
      return unless (env = Environment.find_by(name: options.environment))

      Namespace.create(environment: env, name: args.name)
    end

    # TODO: Move generator to the model?
    def execute
      generator = NamespaceGenerator.new([args.name], options)
      generator.behavior = args.behavior if args.behavior
      generator.invoke_all
    end
  end
end
