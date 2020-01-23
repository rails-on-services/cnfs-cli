# frozen_string_literal: true

class ApplicationGenerator < Thor::Group
  include Thor::Actions
  attr_accessor :deployment, :target, :application, :write_path
  attr_accessor :environment, :name

  private

  def source_paths
    [user_views_path, views_path]
  end

  def user_views_path
    Cnfs.root.join(views_path.to_s.gsub("#{Cnfs.gem_root}/app", 'app'))
  end

  def views_path
    @views_path ||= internal_path.join('../views')
                                 .join(self.class.name.demodulize.delete_suffix('Generator').underscore)
  end

  def internal_path
    Pathname.new(__dir__)
  end

  def path_type
    nil
  end

  def services
    @services ||= (target.services + application.services)
  end

  def resources
    @resources ||= (target.resources + application.resources)
  end

  def entity_to_template(entity = nil)
    entity ||= instance_variable_get("@#{entity_name}")
    key = entity.template || (entity.type ? entity.type.demodulize.underscore : entity.name)
    entity_template_map[key.to_sym] || key
  end

  def entity_template_map
    {}
  end

  def generate_entity_manifests
    entities.each do |entity|
      instance_variable_set("@#{entity_name}", entity)
      generated_files << generate
    end
  rescue StandardError => e
    # TODO: add to errors array and have controller output the result
    error_on = instance_variable_get("@#{entity_name}")
    puts "\nError generating #{entity_name} #{error_on.name}: #{e}"
    puts "\n#{error_on.to_json}"
    exit
  end

  def remove_stale_files
    (all_files - excluded_files - generated_files).each do |file|
      remove_file(file)
    end
  end

  def all_files
    Dir[target.write_path(path_type).join('**/*')]
  end

  def excluded_files
    []
  end

  def generated_files
    @generated_files ||= []
  end
end
