# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :namespace

  validates :name, presence: true

  class << self
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
          ns_services_hash = o_config.to_hash.transform_keys! { |key| "#{env}_#{ns}_#{key}" }.deep_stringify_keys
          hash.merge!(ns_services_hash)
        end
      end
      write_fixture(output)
    end
    # rubocop:enable Metrics/MethodLength
  end

  store :config, accessors: %i[path image depends_on ports mount], coder: YAML
  store :config, accessors: %i[shell_command], coder: YAML

  # depends_on is used by compose to set order of container starts
  # shell_command: the command ShellController passes to runtime.exec
  after_initialize do
    self.depends_on ||= []
    self.shell_command ||= :bash
  end

  def test_commands(_options = nil)
    []
  end
end
