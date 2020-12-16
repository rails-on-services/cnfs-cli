# frozen_string_literal: true

module Environments
  class CrudController
    include ExecHelper
    include TtyHelper

    def update
      return unless (env = Environment.find_by(name: args.name))
      result = Environments::View.new.render(env)
      env.update(result)
    end

    def add
      Environment.create(name: args.name)
    end

    def x_add
      cloud = prompt.enum_select('Cloud Provider:', cloud_providers)
      builder = 'terraform' # for now just TF
      bps = blueprint_types.select { |b| b.start_with?("#{cloud}/#{builder}/") }.map{ |p| p.split('/').last }
      bp_name = prompt.enum_select('Blueprint:', bps)
      klass = ['blueprint', cloud, builder, bp_name].join('/').classify
      return unless (bp_klass = klass.safe_constantize)

      bp = bp_klass.new
      view = "#{bp_klass}::View"
      view_klass = view.safe_constantize
      result = view_klass.new.render(bp)
      # env = Environment.create(name: args.name)
      binding.pry
      # env.blueprints << bp.

      type = prompt.enum_select('Environment Type:', environment_types)
      klass = "Environment::#{type}".classify.safe_constantize
      env = klass.new
      result = Environments::View.new.render(env)
      env = klass.create(config: result, name: args.name, builder: Builder.find_by(name: :terraform))
      env.resource_list.each do |resource_klass|
        res = resource_klass.safe_constantize.new 
        view = "#{resource_klass}::View".safe_constantize.new 
        res.environment = env
        result = view.render(res)
        binding.pry
        res.update(result)
      end
    end

    def destroy
      Environment.find_by(name: args.name).destroy
      # else
      #   klass = "Environment::#{type}".classify.safe_constantize
      #   # TODO: This saves into config/environments.yml
      #   klass.create(config: answers, name: args.name, builder: Builder.find_by(name: :terraform))
      # end
    end

    def cloud_providers
      blueprint_types.map { |p| p.split('/').first }
    end


    def blueprint_types
      @blueprint_types ||= get_blueprint_types
    end

    def get_blueprint_types
      Cnfs.plugins.values.each_with_object([]) do |p, ary|
        path = p.plugin_lib.gem_root.join('app/models/blueprint')
        next unless path.exist?

        Dir.chdir(path) { ary.concat(Dir['**/*.rb']) }
      end.map { |p| p.delete_suffix('.rb') }.select { |p| p.split('/').size > 1 }
    end

    # This is for adding a new Env:
    def environment_types
      # Cnfs.plugins.values.each do |p|
      # Cnfs.loader.preload(Dir[p.plugin_lib.gem_root.join('app/models/*/*.rb')])

      types = Environment.subclasses.map { |s| s.name.demodulize }
    end

    # def execute
    #   # prompt for type of Environment
    #   # The type determines the questions
    #   # binding.pry
    #   generator = EnvironmentGenerator.new([args.name], options)
    #   generator.behavior = args.behavior if args.behavior
    #   generator.invoke_all
    # end
  end
end
