# frozen_string_literal: true

class GeneratorBase < Thor::Group
  include Thor::Actions
  attr_accessor :deployment, :target, :application, :write_path
  attr_accessor :environment, :name

  private

  def source_paths; [user_views_path, views_path] end

  def user_views_path; Cnfs::Core.root.join(views_path.to_s.gsub("#{Cnfs::Core.gem_root}/app", 'lib/generators')) end

  def views_path; internal_path.join('../views').join(self.class.name.delete_suffix('Generator').underscore) end

  def internal_path; Pathname.new(__dir__) end

  def all_files; Dir[target.write_path(path_type).join('**/*')] end

  def excluded_files; [] end

  def path_type; nil end
end
