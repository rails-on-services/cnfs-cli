# frozen_string_literal: true

class NewGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_project_files
    directory('files', '.')
    template('cnfs', '.cnfs')
  end

  def setup_project
    Cnfs.setup_paths(destination_root)
  end

  def generate_encryption_keys
    template('config/keys.yml.erb', Cnfs.user_config_path.join('keys.yml'))
  end

  def generate_default_configs
    configs.each { |type| template("config/#{type}.yml.erb", "config/#{type}.yml") }
  end

  private

  def environments; %w[development test production] end

  def configs; %w[deployments applications] end

  def source_paths; [views_path, views_path.join('templates')] end

  def views_path; @views_path ||= internal_path.join('../views/new') end

  def internal_path; Pathname.new(__dir__) end
end
