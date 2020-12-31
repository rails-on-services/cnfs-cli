# frozen_string_literal: true

module Builds
  class CrudController
    include ExecHelper
    include TtyHelper

    # rubocop:disable Metrics/AbcSize
    def apply
      return unless (build = Build.find_by(name: args.name))

      build.execute_path.mkpath unless build.execute_path.exist?
      Dir.chdir(build.execute_path) do
        BuildGenerator.new([build], options).invoke_all
        build.render
        command.run!({ 'PACKER_CACHE_DIR' => Cnfs.project.cache_path.to_s },
                     "packer build --force #{build.packer_file}")
      end
    end
    # rubocop:enable Metrics/AbcSize

    # Creates the infrastructure using the selected blueprint
    # def apply
    #   environment = Environment.find_by(name: options.environment)
    #   return unless (blueprint = environment.blueprints.find_by(name: args.name))

    #   blueprint.builder.apply
    # end

    # def create
    #   return unless (blueprint_class = blueprint_class_name.safe_constantize)

    #   environment = Environment.find_by(name: options.environment)
    #   blueprint = blueprint_class.new(name: args.name, environment: environment)
    #   blueprint_view = blueprint.view_class.new(model: blueprint)
    #   blueprint_view.edit
    #   blueprint.save

    #   blueprint.resource_classes.each do |resource_class|
    #     prompt.say("\n#{resource_class.name.demodulize}:", color: :yellow)
    #     resource = resource_class.new(blueprint: blueprint)
    #     resource_view = resource.view_class.new(model: resource)
    #     resource_view.edit
    #     resource.save
    #   end
    # end

    # # TODO: Test this method
    # def delete
    #   Environment.find_by(name: options.environment).blueprints.find_by(name: args.name).destroy
    # end

    def describe
      environment = Environment.find_by(name: options.environment)
      return unless (blueprint = environment.blueprints.find_by(name: args.name))

      puts blueprint.as_save.except(:name)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def list
      require 'tty-tree'
      data = Build.order(:name).each_with_object({}) do |build, hash|
        hash[build.name] = children = []
        children.append({ builders: build.builders.pluck(:name) }) if build.builders.any?
        children.append({ provisioners: build.provisioners.order(:order).pluck(:name) }) if build.provisioners.any?
        if build.post_processors.any?
          children.append({ 'post-processors': build.post_processors.order(:order).pluck(:name) })
        end
      end
      data = { Cnfs.project.name => [data] }
      puts TTY::Tree.new(data).render
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    # def update
    #   bps = project.environment.blueprints.pluck(:name)
    #   bp_name = args.name # prompt.enum_select('Blueprint:', bps)
    #   blueprint = project.environment.blueprints.find_by(name: bp_name)

    #   blueprint.resources.each do |resource|
    #     prompt.say("\n#{resource.type.demodulize}:", color: :yellow)
    #     view_klass = "#{resource.type}::View".safe_constantize
    #     view_klass.new.render(resource)
    #     resource.save
    #   end
    #   blueprint.write_template
    # end
  end
end
