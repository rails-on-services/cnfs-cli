# frozen_string_literal: true

module Repositories
  class NewController < Thor
    OPTS = %i[force noop quiet verbose]
    include Cnfs::Options
    include Concern

    private

    def create_repository(type, name)
      generator_name = "#{type}/repository_generator"
      unless (generator_class = generator_name.classify.safe_constantize)
        raise Cnfs::Error, set_color("#{generator_name} class not found. This is a bug. please report", :red) 
      end

      generator = generator_class.new(['restogy', name], options)
      generator.destination_root = Cnfs.paths.src.join(name)
      generator.invoke_all

      update_config(name, repo_type: type)
    end
  end
end
