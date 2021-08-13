# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Service < ApplicationRecord
  attr_accessor :command_queue

  include Concerns::Taggable
  include Concerns::HasEnvs

  # belongs_to :namespace
  # belongs_to :location
  belongs_to :owner, polymorphic: true
  belongs_to :origin, class_name: 'Service'
  has_many :services, as: :origin # , class_name: 'Service'
  # belongs_to :repository, required: false

  store :commands, accessors: %i[console shell test], coder: YAML
  store :commands, accessors: %i[after_service_starts before_service_stops before_service_terminates], coder: YAML
  # store :config, accessors: %i[path image depends_on ports mount], coder: YAML
  store :config, accessors: %i[path depends_on ports mount], coder: YAML
  store :image, accessors: %i[build_args dockerfile repository_name tag], coder: YAML
  store :profiles, coder: YAML

  serialize :volumes, Array

  delegate :project, to: :namespace
  delegate :runtime, to: :project
  delegate :full_context_name, :write_path, to: :project
  delegate :git, to: :repository

  validates :name, presence: true

  validate :image_values

  default_scope { where(context: Cnfs.context) }

  def as_save
    attributes.except('id', 'name', 'origin_id', 'owner_id', 'owner_type')
      .merge('origin' => origin&.name, 'owner' => "#{owner.name} (#{owner_type})")
  end

  def volumes
    super.map(&:with_indifferent_access)
  end

  # rubocop:disable Metrics/AbcSize
  def image_values
    %i[source_path target_path].each do |path|
      next unless build_args.try(:[], path)

      source_path = Cnfs.paths.src.join(build_args[path])
      errors.add(:source_path_does_not_exist, "'#{source_path}'") unless source_path.exist?
    end
    return unless dockerfile

    source_path = Cnfs.paths.src.join(dockerfile)
    errors.add(:dockerfile_path_does_not_exist, "'#{source_path}'") unless source_path.exist?
  end
  # rubocop:enable Metrics/AbcSize

  # depends_on is used by compose to set order of container starts
  after_initialize do
    self.command_queue ||= []
    self.depends_on ||= []
    self.profiles ||= {}
  end

  # parse_scopes :environments, :environment, :namespace
  # parse_sources :project, :user

  # Custom callbacks
  { start: :running, stop: :stopped, terminate: :terminated }.each do |command, state|
    define_model_callbacks command
    define_method(command) do
      run_callbacks(command) do
        update_runtime(state: state)
      end
    end
  end

  after_start { add_commands_to_queue(after_service_starts) }
  before_stop { add_commands_to_queue(before_service_stops) }
  before_terminate { add_commands_to_queue(before_service_terminates) }

  def add_commands_to_queue(commands_array)
    return unless commands_array&.any?

    commands_array.each do |command|
      command_queue.append(Cnfs.project.runtime.exec(self, command, true))
      Cnfs.logger.debug "#{name} command_queue add: #{command}"
    end
  end

  # NOTE: Commands that execute on only one service are implemented here
  # Commands that execute on multiple services are handled directly by the runtime (or namespace?)
  def attach
    runtime.attach(self)
  end

  def console
    runtime.exec(self, commands[:console], true)
  end

  def copy(src, dest)
    runtime.copy(self, src, dest)
  end

  def exec(command)
    runtime.exec(self, command, true)
  end

  def logs
    runtime.logs(self)
  end

  def shell
    project.environment.runtime_for(self).exec(self, commands[:shell], true)
  end

  def test_commands(_options = nil)
    runtime.exec(self, commands[:test], true)
  end

  # def full_path
  #   repository.services_path.join(name)
  # end

  private

  # State handling
  def update_runtime(values)
    runtime_config = YAML.load_file(runtime_path) || {}
    Cnfs.logger.info "Current runtime state for service #{name} is #{runtime_config}"
    runtime_config.merge!(name => values).deep_stringify_keys!
    Cnfs.logger.info "Updated runtime state for service #{name} is #{runtime_config}"
    File.open(runtime_path, 'w') { |file| file.write(runtime_config.to_yaml) }
  end

  # File handling
  def runtime_path
    @runtime_path ||= begin
      file_path = write_path(:runtime)
      file_path.mkpath unless file_path.exist?
      file_path = file_path.join('services.yml')
      FileUtils.touch(file_path) unless file_path.exist?
      file_path
    end
  end

  class << self
    def by_profiles(profiles = project.profiles)
      where('profiles LIKE ?', profiles.map { |k, v| "%#{k}: #{v}%" }.join)
    end

    # def parse
    #   # key: 'environments/staging/main/namespace.yml'
    #   super do |_key, output, _opts|
    #     keys = output.keys.select { |output_key| output_key.end_with?('DEFAULTS') }
    #     output.except!(*keys)
    #   end
    # end

    def create_table(schema)
      schema.create_table :services, force: true do |t|
        t.references :owner, polymorphic: true
        t.references :origin # , polymorphic: true
        t.string :_source
        # t.references :repository
        # TODO: Perhaps these are better as strings that can be inherited
        # t.references :source_repo
        # t.references :image_repo
        # t.references :chart_repo
        t.string :commands
        t.string :config
        # TODO: Change to envs
        t.string :environment
        t.string :image
        t.string :name
        t.string :context
        t.string :path
        t.string :profiles
        t.string :tags
        t.string :template
        t.string :type
        t.string :volumes
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
