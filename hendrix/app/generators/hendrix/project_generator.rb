# frozen_string_literal: true

module Hendrix
  class NewGenerator < ApplicationGenerator
    argument :name

    private

    def _component_files
      %w[commands controllers generators models views].each do |type|
        app_file(type)
      end
      binding.pry
      # keep("app/controllers/#{name}/concerns")
      # keep("app/controllers/#{name}/concerns")
      # keep("app/generators/#{name}/concerns")
      # keep("app/models/#{name}/concerns")
      # keep("app/views/#{name}/concerns")
      keep('config/initializers')
    end

    # def keep(keep_path) = create_file(path.join(keep_path, '.keep'))

    def app_file(app_path) = template("templates/application.rb.erb", path.join('app', app_path, "application_#{app_path.singularize}.rb"))

    def gemfile_gem_string(name)
      gem_name = name.empty? ? 'cnfs' : "cnfs-#{name}"
      return "gem '#{gem_name}'" if ENV['CNFS_ENV'].eql?('production')

      name = 'cnfs' if name.empty?
      "gem '#{gem_name}', path: '#{gems_path.join(name)}'"
    end

    def gems_path() = internal_path.join('../../../../../')
  end
end
