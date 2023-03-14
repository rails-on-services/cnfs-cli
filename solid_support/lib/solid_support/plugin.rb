# frozen_string_literal: true

# Plugins add to Extensions with support for
# app commands, controllers, generators, models and views

require_relative 'extension'

module SolidSupport
  class << self
    # Maintain a Hash of all plugins
    def plugins() = @plugins ||= {}

    # Use Zeitwerk to load classes in each plugin's autoload_paths
    def load_plugins
      plugins.values.each do |plugin|
        paths = ['app'] if plugin.config.autoload_paths.empty?
        paths.each do |path|
          add_loader(name: :framework, path: plugin.gem_root.join(path), notifier: plugin)
        end
      end
    end

    # https://github.com/aws/aws-sdk-ruby/blob/version-3/gems/aws-sdk-s3/lib/aws-sdk-s3/bucket.rb#L221
    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Bucket.html

    # Search plugins for concerns to extend a class that includes Concerns::Extendable
    #
    # @example Request syntax with placeholder values
    #
    #   bucket.create({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read
    #     create_bucket_configuration: {
    #       location_constraint: "af-south-1", # accepts af-south-1, ap-east-1, etc
    #     },
    #     grant_full_control: "GrantFullControl",
    #     grant_read: "GrantRead",
    #     grant_read_acp: "GrantReadACP",
    #     grant_write: "GrantWrite",
    #     grant_write_acp: "GrantWriteACP",
    #     object_lock_enabled_for_bucket: false,
    #     object_ownership: "BucketOwnerPreferred", # accepts BucketOwnerPreferred, ObjectWriter, BucketOwnerEnforced
    #   })
    # @param [Hash] options ({})
    # @option options [String] :acl
    #   The canned ACL to apply to the bucket.
    # @option options [Types::CreateBucketConfiguration] :create_bucket_configuration
    #   The configuration information for the bucket.
    # @option options [String] :grant_full_control
    #   Allows grantee the read, write, read ACP, and write ACP permissions on
    #   the bucket.
    def modules_for(klass) # rubocop:disable Metrics/MethodLength
      base_name = "Concerns::#{klass}"
      logger.debug('Searching for', base_name)

      plugins.keys.each_with_object([]) do |plugin_name, ary|
        module_name = plugin_name.to_s.classify
        plugin_module_name = "#{module_name}::#{base_name}"
        next unless (plugin_module = plugin_module_name.safe_constantize)

        logger.debug('Found', plugin_module_name)
        # binding.pry if klass.eql?(RepositoriesController)
        # binding.pry if klass.eql?(SolidSupport::MainController)
        # Ignore anything that is not an A/S::Concern
        next unless plugin_module.is_a?(ActiveSupport::Concern)

        logger.info('Extending', klass, 'from', plugin_module_name)
        ary.append(plugin_module)
      end
    end

    # Return an array of paths within loaded plugins that contain a file by name
    # Used by Generators to get an array of available templates
    def app_paths(type:, klass:, suffix: nil)
      type = type.to_s.pluralize
      klass = klass.to_s.singularize
      suffix = suffix&.to_s
      plugins.each_with_object([]) do |(name, plugin), ary|
        search_path = [type, name.to_s, klass, suffix].compact
        path = plugin.app_path.join(search_path)
        ary.append(path) if path.exist?
      end
    end
  end

  class Plugin < Extension
    class << self
      # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L68
      def inherited(base)
        return if Extension.abstract_extension?(base)

        SolidSupport.plugins[base.to_s] = base
        super
      end

      def initialize!
        # TODO: This is about plugins; Extensions don't ahve an app path
        # Configure all classes in each extension's app path to be autoloaded
        SolidSupport.load_plugins

        # Setup the autoloader; Requires all classes in the app dir
        SolidSupport.loaders.values.map(&:setup)
      end
    end
  end
end
