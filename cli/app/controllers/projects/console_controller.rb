# frozen_string_literal: true

module Projects
  class ConsoleController < CnfsConsoleController
    class << self

      def commands
        %i[projects repositories infra environments blueprints namespaces images services]
      end

      def model_shortcuts
        { bl: Blueprint, bu: Builder, d: Dependency, e: Environment, l: Location, n: Namespace, pr: Provider,
          res: Resource, reg: Registry, rep: Repository, run: Runtime, s: Service, u: User }
      end
    end

    def m
      project.manifest
    end

    def t
      cache[:t] ||= Runtime::Infra::Terraform.new
    end

    def g
      cache[:g] ||= t.generator
    end

    # rubocop:disable Metrics/AbcSize
    def __prompt
      project = Pry::Helpers::Text.blue(Cnfs.project.name)
      env = Cnfs.project.environment.name
      environment_color = env.eql?('production') ? 'red' : env.eql?('staging') ? 'yellow' : 'green'
      environment = Pry::Helpers::Text.send(environment_color, env)
      namespace = Cnfs.project.namespace.name
      proc do |obj, _nest_level, _|
        "[#{project}][#{environment}][#{namespace}] " \
          "(#{Pry.view_clip(obj.class.name.demodulize.delete_suffix('Controller').underscore).gsub('"', '')})> "
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
