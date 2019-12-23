# frozen_string_literal: true

class GeneratorBase < Thor::Group
  include Thor::Actions
  attr_accessor :deployment, :target, :application, :layer, :layer_type, :service, :write_path
  attr_accessor :environment, :name

  private

  def source_paths; [user_views_path, views_path] end

  def user_views_path; Cnfs::Core.root.join(views_path.to_s.gsub("#{Cnfs::Core.gem_root}/app", 'lib/generators')) end

  def views_path; Pathname.new(internal_path).join('../views') end

  def internal_path; __dir__ end

  def generator_options
    { force: @force }
  end

  def call(klass, write_path, target = nil, layer = nil, layer_type = nil, service = nil)
    g = "#{klass}_generator".camelize.safe_constantize.new(args, options.merge(generator_options))
    g.write_path = Pathname.new(write_path)
    # g.destination_root = Pathname.new(write_path)
    g.deployment = deployment
    g.application = deployment.application
    g.target = target if target
    g.layer = layer if layer
    g.layer_type = layer_type if layer_type
    g.service = service if service
    g.invoke_all
    @force ||= g.shell.instance_variable_get('@always_force')
  end
end
