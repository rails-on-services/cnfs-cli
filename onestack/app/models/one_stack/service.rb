# frozen_string_literal: true

module OneStack
  class Service < ApplicationRecord
    # Define operator before inclding Concerns::Target
    def self.operator() = Runtime

      include OneStack::Concerns::Target

      belongs_to :resource, optional: true

      store :commands, accessors: %i[console shell test], coder: YAML
      store :commands, accessors: %i[after_service_starts before_service_stops before_service_terminates], coder: YAML
      store :commands, accessors: %i[attach], coder: YAML
      # store :config, accessors: %i[path image depends_on ports mount], coder: YAML
      store :config, accessors: %i[path depends_on ports mount] # , coder: YAML
      store :image, accessors: %i[build_args dockerfile repository_name tag], coder: YAML
      store :profiles, coder: YAML

      serialize :volumes, Array

      store :envs, coder: YAML

      # validate :image_values

      def volumes() = super.map(&:with_indifferent_access)

      # rubocop:disable Metrics/AbcSize
      def image_values
        %i[source_path target_path].each do |path|
          next unless build_args.try(:[], path)

          source_path = Hendrix.paths.src.join(build_args[path])
          errors.add(:source_path_does_not_exist, "'#{source_path}'") unless source_path.exist?
        end
        return unless dockerfile

        source_path = Hendrix.paths.src.join(dockerfile)
        errors.add(:dockerfile_path_does_not_exist, "'#{source_path}'") unless source_path.exist?
      end
      # rubocop:enable Metrics/AbcSize

      # depends_on is used by compose to set order of container starts
      after_initialize do
        # self.command_queue ||= []
        self.depends_on ||= []
        self.profiles ||= {}
      end

      # after_update :add_commands_to_queue, if: proc { skip_node_create }

      # after_start { add_commands_to_queue(after_service_starts) }
      # before_stop { add_commands_to_queue(before_service_stops) }
      # before_terminate { add_commands_to_queue(before_service_terminates) }

      # (commands_array)
      def add_commands_to_queue
        self.command_queue = case state
                             when attribute_before_last_save(:state)
                               []
                             when 'started'
                               after_service_starts
                             end
        Hendrix.logger.debug "#{name} command_queue add: #{command_queue}" # ".split("\n")}"
      end

      private

      # State handling
      def update_runtime(values)
        runtime_config = YAML.load_file(runtime_path) || {}
        Hendrix.logger.info "Current runtime state for service #{name} is #{runtime_config}"
        runtime_config.merge!(name => values).deep_stringify_keys!
        Hendrix.logger.info "Updated runtime state for service #{name} is #{runtime_config}"
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

        # rubocop:disable Metrics/MethodLength
        def add_columns(t)
          t.references :resource
          t.string :resource_name
          t.references :repository
          t.string :repository_name
          t.string :commands
          t.string :image
          t.string :path
          t.string :profiles
          t.string :template
          t.string :volumes
          t.string :state
          t.string :envs
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
