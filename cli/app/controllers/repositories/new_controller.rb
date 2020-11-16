# frozen_string_literal: true

module Repositories
  class NewController < Thor
    include Cnfs::Options
    include Concern

    # Activate common options
    cnfs_class_options :noop, :quiet, :verbose, :force

    private

    # Another gem includes its commands in this class, e.g. rails, angular, etc
    # This method is then available to those classes
    def create_repository(type, name)
      Cnfs.paths.src.mkpath

      generator_name = "#{type}/repository_generator"
      unless (generator_class = generator_name.classify.safe_constantize)
        raise Cnfs::Error, set_color("#{generator_name} class not found. This is a bug. please report", :red) 
      end

      generator = generator_class.new(['restogy', name], options)
      generator.destination_root = Cnfs.paths.src.join(name)
      generator.invoke_all

      update_config(name, url: '')
      if Cnfs.config.repository.nil?
        o = Config.load_file('cnfs.yml')
        o.repository = name
        o.save
      end
    end
  end
end
