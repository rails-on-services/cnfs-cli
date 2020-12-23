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
      return unless (blueprint_klass = blueprint_klass_name.safe_constantize) &&
        (view_klass = view_klass_name.safe_constantize)

      environment = Environment.find_by(name: options.environment)
      blueprint = blueprint_klass.new(name: args.name, environment: environment)
      view = view_klass.new
      blueprint.config = view.render(blueprint)
      blueprint.save

      blueprint.resource_list.each do |resource_klass_name|
        next unless (resource_klass = resource_klass_name.safe_constantize) &&
          (view_klass = "#{resource_klass_name}::View".safe_constantize)

        resource = resource_klass.new(blueprint: blueprint)
        prompt.say("\n#{resource_klass_name.demodulize}:", color: :yellow)
        view_klass.new.render(resource)
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

    def view_klass_name
      "#{blueprint_klass_name}::View"
    end

    def set_blueprint_klass_name
      # 1. Select a blueprint type to create an instance of staring with the cloud provider
      cloud = prompt.enum_select('Cloud Provider:', cloud_providers)
      # 2. Select the builder tool for creating the infrastructure. For now just TF
      builder = 'terraform'
      # 3. Given user selections from above, display a list of available Blueprints
      bps = blueprint_types.select { |b| b.start_with?("#{cloud}/#{builder}/") }.map{ |p| p.split('/').last }
      bp_name = prompt.enum_select('Blueprint:', bps)
      ['blueprint', cloud, builder, bp_name].join('/').classify
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
  end
end
