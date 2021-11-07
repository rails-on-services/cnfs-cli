# frozen_string_literal: true

module Projects
  class ConsoleController < CnfsCore::ConsoleController
    include ExecHelper

    # before_execute :initialize_project
    around_execute :timer

    class << self
      def commands
        # %i[projects repositories infra environments blueprints namespaces images services]
        %i[project repository resource blueprint image service]
      end

      def model_shortcuts
        # { bl: Blueprint, bu: Builder, c: Context, co: Component, d: Dependency, n: Node, p: Project, pr: Provider,
          # res: Resource, reg: Registry, rep: Repository, run: Runtime, s: Service, u: User }
        { bl: Blueprint, c: Context, co: Component, d: Dependency, e: Environment, n: Node, p: Project, pr: Provider,
          pro: Provisioner, res: Resource, reg: Registry, rep: Repository, run: Runtime, s: Service, u: User }
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

    CnfsCli.asset_names.each do |asset|
      delegate asset.to_sym, to: :context
    end

    def context=(context)
      @context = context
      @__prompt2 = nil
    end

    # rubocop:disable Metrics/AbcSize
    def __prompt2
      @__prompt2 ||= (
      context.component_list.each_with_object([]) do |comp, prompt|
        cfg = CnfsCli.config.components.select{ |ar| ar.name.eql?(comp.c_name) }.first
        color = cfg&.color
        prompt << (color.nil? ? comp.name : Pry::Helpers::Text.send(color.to_sym, comp.name))
      end.join('][')
      )
    end

    def __prompt
      # TODO: if Cnfs.order.index('environment') then colorize it using the following
      # environment_color = env.eql?('production') ? 'red' : env.eql?('staging') ? 'yellow' : 'green'
      proc do |obj, _nest_level, _|
        klass = obj.class.name.demodulize.delete_suffix('Controller').underscore
        label = klass.eql?('console') ? '' : " (#{klass})"
        "[#{__prompt2}]#{label}> "
      end
    end
  end
end
