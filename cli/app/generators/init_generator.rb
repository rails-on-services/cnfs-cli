# frozen_string_literal: true

class InitGenerator < Thor::Group
  include Thor::Actions
  argument :name

  def generate_project_files
    directory('files', '.')
    template('application.yml.erb', '.cnfs/config/application.yml')
    template('application.rb.erb', '.cnfs/config/application.rb')
  end

  def setup_project
    inside(destination_root) { Cnfs.setup }
  end

  def generate_encryption_keys
    template('db/keys.yml.erb', Cnfs.application.path_for('user', 'db').join('keys.yml'))
    inside(destination_root) { Cnfs.application.initialize! }
  end

  def generate_fixtures
    fixture_names.sort.each { |type| template("db/#{type}.yml.erb", ".cnfs/db/#{type}.yml") }
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

  def fixture_names
    Dir[views_path.join('templates/db/*.erb')].map { |f| File.basename(f).delete_suffix('.yml.erb') } - %w[keys]
  end

  def source_paths
    # binding.pry if Cnfs.application
    # How to get the rails gem's template to be the one chosen
    [views_path, views_path.join('templates')]
  end

  def views_path
    @views_path ||= internal_path.join('../views/new')
  end

  def internal_path
    Pathname.new(__dir__)
  end
end
