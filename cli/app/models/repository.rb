# frozen_string_literal: true

class Repository < ApplicationRecord
  store :config, accessors: %i[url repo_type options], coder: YAML

  after_initialize do
    self.options ||= ''
  end

  validates :url, presence: true

  def pull
    return if Dir.exist?(full_path)

    "git clone #{url} #{full_path}"
  end

  def on_delete
    full_path.rmtree if full_path.exist?
  end

  def full_path
    Cnfs.project.write_path(file_name).join(name)
  end

  # TODO: refactor this to a concern so other global models can use it
  # Just move the below methods to the conern
  def delete
    o = Config.load_file(file_path)
    o.delete_field(name)
    o.save
    on_delete
    super
  end

  def file_path
    Cnfs.paths.config.join("#{file_name}.yml")
  end

  def file_name
    self.class.name.underscore.pluralize
  end
end
