# frozen_string_literal: true

class NewGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_project_files
    directory('files', '.')
    template('cnfs.yml.erb', 'cnfs.yml')
    template('cnfs.erb', '.cnfs')
  end

  def setup_project
    Cnfs.setup_paths(destination_root)
    Cnfs.load_project_config
  end

  def generate_encryption_keys
    template('config/keys.yml.erb', Cnfs.user_config_path.join('keys.yml'))
  end

  def generate_default_configs
    configs.each { |type| template("config/#{type}.yml.erb", "config/#{type}.yml") }
  end

  private

  def box_keys
    @box_keys ||= {
      development: Lockbox.generate_key,
      test: Lockbox.generate_key,
      production: Lockbox.generate_key
    }
  end

  def environments
    %w[development test production]
  end

  def configs
    Dir[views_path.join('templates/config/*.erb')].map { |f| File.basename(f).delete_suffix('.yml.erb') } - %w[keys]
  end

  def source_paths
    [views_path, views_path.join('templates')]
  end

  def views_path
    @views_path ||= internal_path.join('../views/new')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
