# frozen_string_literal: true

class GeneratorBase < Thor::Group
  include Thor::Actions
  attr_accessor :deployment, :target, :application, :layer, :service, :write_path
  attr_accessor :environment, :name

  private

  def source_paths; [views_path] end
  def views_path; Pathname.new(internal_path).join('../views') end
  def internal_path; __dir__ end

  # def source_paths; [user_path, a_path, internal_path] end
  # def user_path; options.project_dir.join(a_path.to_s.gsub("#{gem_root}/", '')).join('templates').to_s end
  # def internal_path; "#{a_path}/templates" end
  # internal_path.gsub("#{Cnfs::Core.gem_root}/", '').gsub('generators', 'views').gsub('_generator.rb', '')

  def generator_options
    { force: @force }
  end

  def call(klass, write_path, target = nil, layer = nil, service = nil)
    g = klass.safe_constantize.new(args, options.merge(generator_options))
    g.write_path = write_path
    g.deployment = deployment
    g.application = deployment.application
    g.target = target if target
    g.layer = layer if layer
    g.service = service if service
    g.invoke_all
    @force ||= g.shell.instance_variable_get('@always_force')
  end
end
