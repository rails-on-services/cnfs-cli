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
      return unless (blueprint_class = blueprint_class_name.safe_constantize)

      environment = Environment.find_by(name: options.environment)
      blueprint = blueprint_class.new(name: args.name, environment: environment)
      blueprint_view = blueprint.view_class.new(model: blueprint)
      binding.pry
      blueprint_view.create
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
      puts data.any? ? TTY::Tree.new(data).render : 'none found'
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

    def blueprint_class_name
      @blueprint_class_name ||= begin
        # 1. Select the target platform from the avialable cloud providers and local
        platforms = Blueprint.available_platforms
        platform = platforms.size.eql?(1) ? platforms.first : prompt.enum_select('Target platform:', platforms)

        # 2. Select the type from the chosen platform's available types
        types = Blueprint.available_types(platform)
        type = types.size.eql?(1) ? types.first : prompt.enum_select('Blueprint:', types)

        "blueprint/#{platform}/#{type}".classify
      end
    end
  end
end
