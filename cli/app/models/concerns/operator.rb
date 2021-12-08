# frozen_string_literal: true

# Add capabilities to specific Asset classes: Builder, Configurator, Provisioner, Runtime
# 1. Generate content from project configuration
# 2. Ensure Operator dependencies are available on the system or download them if requested and available
# 3. Provide Queue mechanism for running OS commands
module Concerns
  module Operator
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks

      include Concerns::Git

      attr_accessor :context

      store :config, accessors: %i[dependencies]

      # binding.pry
      define_model_callbacks :execute
      table_mod(:operator_columns)
    end

    class_methods do
      def operator_columns(t)
        t.string :cache_path         # override the default cache_path for generated content
        t.string :cache_path_suffix  # optional suffix path after appending component's namespace to cache_path
        # t.string :dependencies       # declare array of dependencies to validate
      end
    end

    def execute(method)
      unless supported_commands.include?(method)
        Cnfs.logger.fatal("#{self.class.name} does not support the #{method} command")
        return
      end
      generate
      send(method)
    end

    def supported_commands() = self.class.instance_methods(false)

    # Check if the manifest is valid and run the generator if
    # The manifest is invliad or the user supplied either the --generate or --clean options
    def generate
      path.rmtree if context.options.clean
      path.mkpath
      return if manifest.valid? unless context.options.generate

      # Rather than set generator.destination_root which requires generators to use in_root blocks
      # just cd into path and then invoke the generator
      Dir.chdir(path) { generator.invoke_all }
      if manifest.reload.valid?
        Cnfs.logger.info('manifest validated - OK')
      else
        Cnfs.logger.warn("Invalid manifest: #{manifest.errors.full_messages}")
      end
    end

    def manifest() = @manifest ||= Manifest.new(source_paths: Cnfs.config.paths.component,
                                                destination_path: path)

    # Concatenate base_path with Operator specific values to a unique path on the local file system
    # which will result in something like:
    # ~/xdg_cache_path/cnfs-cli/<project_id>/<project_name>/<component_name>/services/<runtime_name>
    #
    # If the Operator provides a destination path it takes precedence over the context component's cache_path
    #
    # @return [Pathname]
    #
    def path() = @path ||= get_cache_path

    def get_cache_path
      return owner.cache_path.join(asset_type, name) unless cache_path

      Pathname.new(cache_path).join(*owner.attrs).join(cache_path_suffix || '.')
    end

    def generator() = @generator ||= generator_class.new([owner, self])

    # Terraform::Provisioner becomes Terraform::ProvisionerGenerator
    def generator_class() = "#{self.class.name}Generator".constantize

    #
    # Ensure dependencies are available on the system or download them if requested and available
    #
    def dependencies_check
      dependencies.each do |required|
        dependency = Dependency.find_by(name: required['name'])
        if dependency && (version = required['version'])
          dependency.do_download(version)
        end
      end
    end

    # method inherited from A/R base interferes with controller#destroy
    # undef_method :destroy
    # def destroy; end

    def queue() = @queue ||= CommandQueue.new
  end
end
