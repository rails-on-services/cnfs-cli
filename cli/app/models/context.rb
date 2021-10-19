# frozen_string_literal: true
# def parse
#   content = Cnfs.config.to_hash.slice(
#     *reflect_on_all_associations(:belongs_to).map(&:name).append(:name, :paths, :tags)
#   )
#   namespace = "#{content[:environment]}_#{content[:namespace]}"
#   options = Cnfs.config.delete_field(:options).to_hash if Cnfs.config.options
#   output = { 'project' => content.merge(namespace: namespace, options: options) }
#   create_all(output)
# end


class Context < ApplicationRecord
  belongs_to :root, class_name: 'Component'
  belongs_to :component

  store :options, coder: YAML

  Cnfs.config.asset_names.each do |asset_name|
    has_many asset_name.to_sym
  end

  delegate :runtime, to: :component

  class << self
    def after_node_load
      raise Cnfs::Error, 'Context issue' if count.positive?
      obj = create(root: Project.first)
      obj.parse_options
    end
  end

  # TODO: This method needs error checking and then log or raise if supplied params are not found
  def parse_options
    obj = root
    Cnfs.config.order[1..].each do |component_name|
      name = Cnfs.config.send(component_name)
      name ||= Cnfs.config.config.x_components.select{ |c| c.name.eql?(component_name) }.first&.default
      obj = obj.components.find_by(name: name)
    end
    update(component: obj)
    component.update_context(context: self)
  end


  Cnfs.config.order[1..].each do |component_name|
    has_many component_name.pluralize.to_sym
  end

  # attr_accessor :runtime
  # attr_writer :manifest
  # after_create :create_resources
  # before_validation :set_defaults

  def set_defaults
    self.current ||= set_current
  end

  # If options were passed in then ensure the values are valid (names found in the config)
  # validates :environment, presence: { message: 'not found' } # , if: -> { options.environment }
  # validates :namespace, presence: { message: 'not found' } # , if: -> { options.namespace }
  # validate :associations_are_valid

  # TODO: Should there be validations for repository and source_repository?
  # validates :service, presence: { message: 'not found' }, if: -> { arguments.service }
  # validate :all_services, if: -> { arguments.services }
  # validates :runtime, presence: true

  def associations_are_valid
    # errors.copy!(environment.errors) unless environment.valid?
  end

  def repository_is_valid
    # binding.pry
    # raise Cnfs::Error, "Unknown repository '#{options.repository}'." \
    #  " Valid repositories:\n#{Cnfs.repositories.keys.join("\n")}"
  end

  # Start with the most specific component and work back up until finding
  # the context that has been specified either in config or cli options
  def set_current
    Cnfs.config.order.reverse.each do |component_type|
      next unless (name = options[component_type])

      break root.send(component_type.pluralize).find_by(name: name)
    end
  end

  # after_create :create_resources

  def create_resources
    # NOTE: Here use the options to select things like services, resources, etc
    # and combine them using the abstract assets in higher level directories
    # then create records of them with this instance of the Context class as the owner
    # NOTE:
    # Then to any calling services, e.g. compose template creation would just call
    # Cnfs.context.services and that's everything that's needed
  end

  # maintain api for now
  def write_path(type = :manifests)
    path(to: type)
  end

  def path(from: nil, to: nil, absolute: false)
    project_path.path(from: from, to: to, absolute: absolute)
  end

  def project_path
    @project_path ||= ProjectPath.new(self)
  end

  # TODO: Implement options.clean
  # NOTE: If this method is called more than once it will get a new manifest instance each time
  def process_manifests
    @manifest = nil
    manifest.purge! if options.force
    return if manifest.valid?

    manifest.generate
  end

  # TODO: add other dirs for config files, e.g. gem user's path; load from a config file?
  def manifest
    @manifest ||= Manifest.new(project: self, config_files_paths: [paths.config])
  end

  # Used by runtime generators for templates by runtime to query services
  def labels
    { project: full_context_name, environment: environment&.name, namespace: namespace&.name }
  end

  def full_context_name
    context_attrs.unshift(name).join('_')
  end

  def context_name
    context_attrs.join('_')
  end

  def context_attrs
    [environment&.name, namespace&.name].compact
  end

  class << self
    def create_table(schema)
      schema.create_table table_name, force: true do |t|
        t.references :root
        t.references :component
        t.string :options
      end
    end
  end
end
