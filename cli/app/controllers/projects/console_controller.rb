# frozen_string_literal: true

module Projects
  class ConsoleController < CnfsCore::ConsoleController
    class << self
      def commands
        %i[projects repositories infra environments blueprints namespaces images services]
      end

      def model_shortcuts
        { bl: Blueprint, bu: Builder, c: Context, co: Component, d: Dependency, n: Node, p: Project, pr: Provider,
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
      prompt = []
      first = Context.first.root.name
      prompt << Pry::Helpers::Text.blue(first)
      # TODO: If project.config.prompt.eql?('all') then display all component names in the hierarchy
      # including if Cnfs.order.index('environment') then colorize it using the following
      # environment_color = env.eql?('production') ? 'red' : env.eql?('staging') ? 'yellow' : 'green'
      # prompt << Pry::Helpers::Text.send(environment_color, env)
      last = Context.first.component.name
      prompt << last
      proc do |obj, _nest_level, _|
        klass = obj.class.name.demodulize.delete_suffix('Controller').underscore
        label = klass.eql?('console') ? '' : " (#{klass})"
        "[#{prompt.join('][')}]#{label}> "
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
