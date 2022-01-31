# frozen_string_literal: true

require 'ostruct'

module Hendrix
  class ProjectController < ApplicationController
    def version
      unless options.all
        puts "#{parent}    #{parent::VERSION}"
        return
      end
      extensions = Hendrix.extensions.values.map(&:module_parent).append(Hendrix).map(&:to_s)
      pad = extensions.max_by(&:length).size + 4
      extensions.sort.each do |extension|
        puts [extension, ' ' * (pad - extension.length), extension.constantize::VERSION].join
      end
    end

    # Entrypoint for the new command for both Project and Plugin Commands
    def new
      binding.pry
      path.rmtree if path.exist?
      send("new_#{args.type}".to_sym)
    end

    # An Extension is a gem with a lib file that inherits from Hendrix::Extension/Tune
    # 1. create gem is a specific method (Shared with plugin)
    # 2. create extension.rb is a specific method
    def new_extension() = generator.invoke_all

    # A Plugin is an extension but replaces extension.rb with plugin.rb and has an app structure
    # 1. invoke extension#gem
    # 2. create plugin.rb is a specific method
    # 3. create an app structure is a specific method (share with application)
    # 4. create test harness at spec/dummy/app to create app structure is a specific method
    # 5. create app config at spec/dummy/config is a specific method (share with application)
    def new_plugin
      generator(:extension).invoke(:gem)
      generator(:extension).invoke(:gem_libs)
      generator(:extension).invoke(:gem_root_files)
      generator(:extension).invoke(:app_structure)
      generator.invoke_all
    end

    # An application:
    # 1. invokes plugin#app_structure
    # 2. invoke plugin#app_config but create at the root of the project
    # NOTE: An application is just a plugin with some extra stuff
    def new_application
      generator(:plugin).invoke(:app_dir_structure)
      generator(:plugin).invoke(:app_structure)
      generator.invoke_all
    end

    def generator(type = args.type)
      @generators ||= {}
      return @generators[type] if @generators[type]

      # TODO: The string 'hendrix' can be passed in as an argument from the ProjectController
      @generators[type] ||= generator_class(type).new([name, parent_name], options)
      # All Thor methods are automatically invoked inside destination_root
      @generators[type].destination_root = name
      @generators[type]
    end

    # def generator_class(type) =  "hendrix/project/#{type}_generator".classify.constantize
    def generator_class(type) = "#{parent_name}/project/#{type}_generator".classify.constantize

    def name() = @name ||= path.name

    def path() = @path ||= Pathname.new(args.path)
  end
end
