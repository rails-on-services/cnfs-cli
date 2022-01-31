# frozen_string_literal: true

require 'ostruct'

module Hendrix
  class NewController < ApplicationController
    def new
      path.rmtree if path.exist?
      send(args.type)
    end

    def project
      path.mkdir
      binding.pry
      Dir.chdir(path) { generator.invoke_all }
      # Dir.chdir(path) { generator(:extension).invoke(:segments) }

      # Dir.chdir(path) do
      #   Hendrix.loaders['framework'].unload
      #   load 'cnfs/boot_loader.rb'
      #   SegmentRoot.first.generate_key
      # end

      return unless context.options.guided

      # Start a view here
      # TODO: This should create a node which should create a file with the yaml or a directory
      # Project.new(name: context.args.name).create
    end

    def plugin
      generator.invoke_all
      Dir.chdir(path) { generator(:extension).invoke(:segments) }
    end

    def extension
      path.mkdir
      Dir.chdir(path) { generator.invoke_all }
    end

    def generator(type = args.type) = generator_class(type).new([context, name], options)

    def generator_class(type) =  "hendrix/new/#{type}_generator".classify.constantize

    def name() = @name ||= path.basename.to_s

    def path() = @path ||= Pathname.new(args.path)

    # TODO: To be compaitble with CnfsCli::Concerns::CommandController
    # this should be removed or consolidated
    def context() = OpenStruct.new(options: options, args: args)
  end
end
