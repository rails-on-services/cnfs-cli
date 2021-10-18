# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Cnfs::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # after_destroy :destroy_in_file
  # after_save :save_in_file

  def edit
    view.edit
    update(attributes)
    self
  end

  def view
    view_class.new(model: self)
  end

  def view_class
    self.class::View
  end

  # TODO: Implement in nodes
  def destroy_in_file
    content = YAML.load_file(save_path).to_h
    content = content.except(name).to_yaml
    File.open(save_path, 'w') { |file| file.write(content) }
  end

  def save_in_file
    save_path.split.first.mkpath unless save_path.split.first.exist?
    content = YAML.load_file(save_path) if save_path.exist?
    content ||= {}
    # binding.pry
    # as_save = as_save.except('_source_path')
    new_content = fixture_is_singular? ? as_save : { name => as_save }
    new_content = JSON.parse(new_content.to_json)
    content.merge!(new_content)
    File.open(save_path, 'w') { |file| file.write(content.to_yaml) }
  end

  def fixture_is_singular?
    fp = save_path.split.last.to_s.delete_suffix('.yml')
    fp.eql?(fp.singularize)
  end

  # Override to provide a path alternative to config/table_name.yml
  def save_path
    # Cnfs.project_root.join(Cnfs.project.paths.config).join("#{self.class.table_name}.yml")
  end

  def as_save
    raise NotImplementedError, 'Must return a hash of attributes'
  end
end
