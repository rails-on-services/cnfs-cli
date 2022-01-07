# frozen_string_literal: true
#
# Plugins add to Extension with support for
# app controllers, generators, models and views
# config and inline initializers

require 'cnfs/extension'

module Cnfs
  class << self
    def run_initializers
      plugins.each do |name, plugin|
        initializers.select{ |init| init[:name].eql?(plugin.to_s) }.each { |init| init[:block].call }
        plugin.initializer_files.each { |file| require file }
      end
    end

    # Record initializers to be run after the application has loaded
    def initializers() = @initializers ||= []

    # Maintain a Hash of all plugins
    def plugins() = @plugins ||= {}

    # https://github.com/aws/aws-sdk-ruby/blob/version-3/gems/aws-sdk-s3/lib/aws-sdk-s3/bucket.rb#L221
    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Bucket.html

    # Search plugins for concerns to extend a class that includes Concerns::Extendable
    #
    # @example Request syntax with placeholder values
    #
    #   bucket.create({
    #     acl: "private", # accepts private, public-read, public-read-write, authenticated-read
    #     create_bucket_configuration: {
    #       location_constraint: "af-south-1", # accepts af-south-1, ap-east-1, ap-northeast-1, ap-northeast-2, ap-northeast-3, ap-south-1, ap-southeast-1, ap-southeast-2, ca-central-1, cn-north-1, cn-northwest-1, EU, eu-central-1, eu-north-1, eu-south-1, eu-west-1, eu-west-2, eu-west-3, me-south-1, sa-east-1, us-east-2, us-gov-east-1, us-gov-west-1, us-west-1, us-west-2
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
    def modules_for(klass)
      base_name = "Concerns::#{klass}"
      Cnfs.logger.debug('Searching for', base_name)

      Cnfs.plugins.keys.each_with_object([]) do |plugin_name, ary|
        module_name = plugin_name.to_s.classify
        plugin_module_name = "#{module_name}::#{base_name}"
        next unless (plugin_module = plugin_module_name.safe_constantize)

        Cnfs.logger.debug('Found', plugin_module_name)
        # binding.pry if klass.eql?(RepositoriesController)
        # binding.pry if klass.eql?(Cnfs::MainController)
        # Ignore anything that is not an A/S::Concern
        next unless plugin_module.is_a?(ActiveSupport::Concern)

        Cnfs.logger.info('Extending', klass, 'from', plugin_module_name)
        ary.append(plugin_module)
      end
    end

    def app_paths(type:, klass:, suffix: nil)
      type = type.to_s.pluralize
      klass = klass.to_s.singularize
      suffix = suffix&.to_s
      Cnfs.plugins.each_with_object([]) do |(name, plugin), ary|
        search_path = [type, name.to_s, klass, suffix].compact
        path = plugin.app_path.join(search_path)
        ary.append(path) if path.exist?
      end
    end
  end

  class Plugin < Extension
    class << self
      # Called one or more times by subclasses to execute a block of code after application initialization
      def initializer(init_name, &block)
        Cnfs.initializers.append({ name: name, init_name: init_name, block: block })
      end

      def initializer_files() = initializers_path.exist? ? initializers_path.glob('**/*.rb') : []

      def initializers_path() = config_path.join('initializers')

      def config_path() = gem_root.join('config')

      def app_path() = gem_root.join('app')

      def root() = gem_root

      # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L68
      def inherited(base)
        name = name_from_base(base)
        return if base.to_s.eql?('Cnfs::Application')

        Cnfs.plugins[name] = base
        super
      end
    end
  end
end
