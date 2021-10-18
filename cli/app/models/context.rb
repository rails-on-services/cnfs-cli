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
  belongs_to :owner, polymorphic: true
  belongs_to :component, polymorphic: true
  belongs_to :parent, class_name: 'Node'

  store :options, coder: YAML

  # (Cnfs.config.asset_names - ['context']).each do |asset_name|
  # has_many asset_name.to_sym
  # end

  delegate :runtime, to: :component

  class << self
    def after_node_load
      obj = first_or_create(owner: Project.first)
      parse_options
      obj.component&.update_context(context: obj)
    end

    def parse_options
      # TODO
      # binding.pry
    end
  end


  # Cnfs.config.order.each do |component_name|
  #   belongs_to component_name.to_sym
  # end
  # binding.pry

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
        t.references :owner, polymorphic: true
        t.references :component, polymorphic: true
        t.references :parent
        # Cnfs.config.order.each do |component_name|
        #   t.references component_name.to_sym
        # end
        t.string :name
        t.string :options
        # t.string :environment
        # t.string :namespace
        # t.string :stack
        # t.string :target
      end
    end
  end
end
