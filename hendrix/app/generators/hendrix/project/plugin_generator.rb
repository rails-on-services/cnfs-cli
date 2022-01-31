# frozen_string_literal: true

module Hendrix
  class Project::PluginGenerator < ProjectGenerator
    attr_accessor :type

    def app_dir_structure
      %w[commands controllers generators records views].each do |type|
        @type = type
        app_file(type)
      end
    end

    # Set this to spec/dummy so that app_structure templates files in this directory
    def set_dest_root() = self.destination_root = "#{name}/spec/dummy"

    def app_structure() = super

    private

    def app_file(app_path)
      ap = app_path.eql?('records') ? 'models' : app_path
      template("m_templates/application.rb.erb", path.join('app', ap, "application_#{app_path.singularize}.rb"))
    end

    def uuid() = @uuid ||= SecureRandom.uuid

    def internal_path() = Pathname.new(__dir__)
  end
end

