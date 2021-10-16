# frozen_string_literal: true

module Projects
  class ConsoleController < CnfsCore::ConsoleController
    class << self
      def commands
        %i[projects repositories infra environments blueprints namespaces images services]
      end

      def model_shortcuts
        { bl: Blueprint, bu: Builder, c: Context, d: Dependency, e: Environment, l: Location, n: Node, nam: Namespace, pr: Provider,
          res: Resource, reg: Registry, rep: Repository, run: Runtime, s: Service, st: Stack, u: User }
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
      prompt = []
      prompt << Pry::Helpers::Text.blue('happy') #Cnfs.project.name)
      env = 'essay' # Cnfs.project.environment.name
      environment_color = env.eql?('production') ? 'red' : env.eql?('staging') ? 'yellow' : 'green'
      prompt << Pry::Helpers::Text.send(environment_color, env)
      prompt << 'krash' # Cnfs.project.namespace.name
      proc do |obj, _nest_level, _|
        klass = obj.class.name.demodulize.delete_suffix('Controller').underscore
        label = klass.eql?('console') ? '' : " (#{klass})"
        "[#{prompt.join('][')}]#{label}> "
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
