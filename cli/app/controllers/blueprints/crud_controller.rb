# frozen_string_literal: true

module Blueprints
  class CrudController
    include ExecHelper
    include TtyHelper

    # Creates the infrastructure using the selected blueprint
    def apply
      environment = Environment.find_by(name: options.environment)
      return unless (blueprint = environment.blueprints.find_by(name: args.name))

      blueprint.builder.apply
    end

    def create
      return unless (blueprint_klass = blueprint_klass_name.safe_constantize)

      environment = Environment.find_by(name: options.environment)
      blueprint = blueprint_klass.new(name: args.name, environment: environment)
      blueprint_view = blueprint.view_class.new(model: blueprint)
      blueprint_view.edit
      blueprint.save

      blueprint.resource_classes.each do |resource_class|
        prompt.say("\n#{resource_class.name.demodulize}:", color: :yellow)
        resource = resource_class.new(blueprint: blueprint)
        resource_view = resource.view_class.new(model: resource)
        resource_view.edit
        resource.save
      end
    end

    # # TODO: Test this method
    # def delete
    #   Environment.find_by(name: options.environment).blueprints.find_by(name: args.name).destroy
    # end

    def describe
      environment = Environment.find_by(name: options.environment)
      return unless (blueprint = environment.blueprints.find_by(name: args.name))

      puts blueprint.as_save.except(:name)
    end

    # TODO: Use TTY-tree to list all envs
    def list
      require 'tty-tree'
      data = Environment.order(:name).each_with_object({}) do |env, hash|
        hash[env.name] = env.blueprints.pluck(:name)
      end
      puts TTY::Tree.new(data).render
    end

    def update
      bps = project.environment.blueprints.pluck(:name)
      bp_name = args.name # prompt.enum_select('Blueprint:', bps)
      blueprint = project.environment.blueprints.find_by(name: bp_name)

      blueprint.resources.each do |resource|
        prompt.say("\n#{resource.type.demodulize}:", color: :yellow)
        view_klass = "#{resource.type}::View".safe_constantize
        view_klass.new.render(resource)
        resource.save
      end
      blueprint.write_template
    end

    private

    def blueprint_klass_name
      @blueprint_klass_name ||= set_blueprint_klass_name
    end

    def set_blueprint_klass_name
      # 1. Select a blueprint type to create an instance of staring with the cloud provider
      platform = prompt.enum_select('Target platform:', available_platforms)
      # 2. Select the builder tool for creating the infrastructure. For now just TF
      builders = available_builders(platform)
      builder =
        if builders.size.eql?(1)
          prompt.ok("Builder: #{builders.first}")
          builders.first
        else
          prompt.enum_select('Builder:', available_builders(platform))
        end
      # 3. Given user selections from above, display a list of available Blueprints
      bps = blueprint_types.select { |b| b.start_with?("#{platform}/#{builder}/") }.map{ |p| p.split('/').last }
      bp_name = prompt.enum_select('Blueprint:', bps)
      ['blueprint', platform, builder, bp_name].join('/').classify
    end

    def available_builders(platform)
      blueprint_types.select{|p| p.start_with?(platform) }.map { |p| p.split('/').second }.sort
    end

    def available_platforms
      blueprint_types.map { |p| p.split('/').first }.sort
    end

    def blueprint_types
      @blueprint_types ||= get_blueprint_types
    end

    def get_blueprint_types
      Cnfs.plugins.values.append(Cnfs).each_with_object([]) do |p, ary|
        path = p.plugin_lib.gem_root.join('app/models/blueprint')
        next unless path.exist?

        Dir.chdir(path) { ary.concat(Dir['**/*.rb']) }
      end.map { |p| p.delete_suffix('.rb') }.select { |p| p.split('/').size > 1 }
    end
  end
end
