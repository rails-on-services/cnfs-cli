# frozen_string_literal: true

class Service < ApplicationRecord
  include Taggable

  belongs_to :namespace

  delegate :project, :runtime, to: :namespace

  delegate :full_context_name, :write_path, to: :project

  validates :name, presence: true

  store :config, accessors: %i[path image depends_on ports mount], coder: YAML
  store :config, accessors: %i[shell_command], coder: YAML
  store :profiles, coder: YAML

  # depends_on is used by compose to set order of container starts
  after_initialize do
    self.depends_on ||= []
  end

  def update_state(state)
    file_path = write_path(:runtime).join('services.yml')
    FileUtils.touch(file_path) unless File.exist?(file_path)
    o = Config.load_file(file_path)
    hash = { name => { state: state } }
    Cnfs.logger.info "State for service #{name} updated to #{hash}"
    method = "after_#{state}"
    additional_commands = respond_to?(method) ? send(method, hash) : []
    o.merge!(hash)
    o.save
    additional_commands
  end

  # NOTE: Commands that execute on only one service are implemented here
  # Commands that execute on multiple services are handled directly by the runtime (or namespace?)
  def attach
    runtime.attach(self)
  end

  def console
    runtime.exec(self, console_command, true)
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
    runtime.exec(self, shell_command, true)
  end

  def test_commands(_options = nil)
    []
  end

  class << self
    def by_profiles(profiles = project.profiles)
      where("profiles LIKE ?", profiles.map { |k, v| "%#{k}: #{v}%" }.join)
    end

    # rubocop:disable Metrics/MethodLength
    def parse
      file_name = 'config/environments/services.yml'
      files = File.exist?(file_name) ? [file_name] : []
      output = environments.each_with_object({}) do |env_path, hash|
        file_name = env_path.join('services.yml')
        env_files = File.exist?(file_name) ? files + [file_name] : files
        env = env_path.split.last.to_s
        env_path.children.select(&:directory?).each do |ns_path|
          file_name = ns_path.join('services.yml')
          ns_files = File.exist?(file_name) ? env_files + [file_name] : env_files
          ns = ns_path.split.last.to_s
          o_config = ns_files.each_with_object(Config::Options.new) do |file, cfg|
            cfg.merge!(Config.load_files(file).to_hash)
          end
          o_config.keys.each do |key|
            o_config[key].name = key.to_s
            o_config[key].namespace = "#{env}_#{ns}"
          end
          ns_services_hash = o_config.to_hash.except(:DEFAULTS).transform_keys! { |key| "#{env}_#{ns}_#{key}" }.deep_stringify_keys
          hash.merge!(ns_services_hash)
        end
      end
      write_fixture(output)
    end
    # rubocop:enable Metrics/MethodLength
  end
end
