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
        { b: Blueprint, c: Context, co: Component, d: Dependency, i: Image, n: Node, p: Project, pr: Provider,
          pro: Provisioner, r: Resource, re: Repository, reg: Registry, ru: Runtime, s: Service, u: User }
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

    CnfsCli.asset_names.append(:root, :component).each do |asset|
      delegate asset.to_sym, to: :context
    end

    def context=(context)
      @context = context
      @__prompt2 = nil
    end

    # rubocop:disable Metrics/AbcSize
    def __prompt2
      @__prompt2 ||= context.component_list.each_with_object([]) do |comp, prompt|
        # cfg = CnfsCli.config.components.select { |ar| ar.name.eql?(comp.segment_type) }.first
        # color = cfg&.color
        # TODO: if the color is specified that remove it from the colors array so it isn't resused
        # prompt << (color.nil? ? comp.name : Pry::Helpers::Text.send(color.to_sym, comp.name))
        # TODO: If option is not verbose then don't show segment_type
        title = "#{comp.segment_type}:#{comp.name}"
        prompt << (Pry::Helpers::Text.send(colors.shift, title))
      end.join('/')
    end

    def colors
      @colors ||= %i[blue green purple magenta cyan yellow red white black]
    end

    def __prompt
      # TODO: if Cnfs.order.index('environment') then colorize it using the following
      # environment_color = env.eql?('production') ? 'red' : env.eql?('staging') ? 'yellow' : 'green'
      proc do |obj, _nest_level, _|
        klass = obj.class.name.demodulize.delete_suffix('Controller').underscore
        label = klass.eql?('console') ? '' : " (#{klass})"
        "#{__prompt2}#{label}> "
      end
    end
  end
end
