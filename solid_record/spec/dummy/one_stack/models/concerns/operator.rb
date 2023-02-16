# frozen_string_literal: true

# Add capabilities to specific Asset classes: Builder, Configurator, Provisioner, Runtime
# 1. Generate content from project configuration
# 2. Ensure Operator dependencies are available on the system or download them if requested and available
# 3. Provide Queue mechanism for running OS commands
module OneStack
  module Concerns::Operator
    extend ActiveSupport::Concern

    included do
      include Concerns::Asset

      store :config, accessors: %i[dependencies]

      # Operators can declare methods to invoke before, after or around that will apply to all implemented commands
      define_model_callbacks :execute

      table_mod(:operator_columns)

      # include SolidApp::Extendable
    end

    def execute(method, **kwargs)
      unless self.class.commands.include?(method)
        OneStack.logger.fatal("#{self.class.name} does not support the #{method} command")
        return
      end

      assign_attributes(**kwargs)

      run_callbacks(:execute) do
        run_target_callbacks(method, :before)
        send(method)
        run_target_callbacks(method, :after)
      end
    end

    def run_target_callbacks(method, event)
      send(self.class.target).each do |instance|
        callbacks = instance.class.send("_#{method}_callbacks").select { |cb| cb.kind.eql?(event) }.collect(&:filter)
        callbacks.each { |cb| instance.send(cb, self) }
      end
    end

    # Check if the manifest is valid and run the generator if
    #   the manifest is invalid OR the user supplied either the --generate or --clean options
    def generate
      path.rmtree if context.options.clean
      path.mkpath
      return if manifest.valid? && !context.options.generate

      binding.pry
      manifest.rm_targets
      OneStack.logger.debug("Processing manifest in #{path}")
      # Rather than set generator.destination_root which requires generators to use in_root blocks
      # just cd into path and then invoke the generator
      Dir.chdir(path) { generator.invoke_all }
      if manifest.reload.valid?
        OneStack.logger.info('manifest validated - OK')
      else
        OneStack.logger.warn("Invalid manifest: #{manifest.errors.full_messages}")
      end
    end

    def manifest() = @manifest ||= Manifest.new(source: source_files, target: target_files)

    def source_files() = proc { Node.all.map(&:rootpath).uniq }

    # TODO: This needs to be able to exclude paths from the root of the target_dir not just int the target_dir
    def target_files
      proc do
        Pathname.new(path).glob('**/*').reject { |p| target_exclude_files.include?(p.basename.to_s) }
      end
    end

    def target_exclude_files() = []

    # Concatenate base_path with Operator specific values to a unique path on the local file system
    # which will result in something like:
    # ~/xdg_cache_path/cnfs/<project_id>/<project_name>/<component_name>/services/<runtime_name>
    #
    # If the Operator provides a destination path it takes precedence over the context component's cache_path
    #
    # @return [Pathname]
    #
    def path() = @path ||= current_cache_path

    def current_cache_path
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

    def context() = owner

    class_methods do
      def operator_columns(t)
        t.string :cache_path         # override the default cache_path for generated content
        t.string :cache_path_suffix  # optional suffix path after appending component's namespace to cache_path
        # t.string :dependencies       # declare array of dependencies to validate
      end

      # Each target class defines its operator class
      # The target concern defines callbacks by calling operator.target_callbacks
      #
      # If the target callbacks should not be defined 1:1 for a specific operator/target pair
      # the operator class should override this method
      #
      # @return [Array]
      #
      def target_callbacks() = commands

      # Each operator class overrides this method to list methods which can be invoked by a Controller
      #
      # STI subclasses may also override this method to add/remove commands from its superclass
      #
      # @return [Array]
      def commands() = %i[]
    end
  end
end
