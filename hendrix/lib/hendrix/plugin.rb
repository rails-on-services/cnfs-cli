# frozen_string_literal: true

# Tunes add to Lyric with support for
# app commands, controllers, generators, models and views

require 'hendrix/lyric'

module Hendrix
  class << self
    # Maintain a Hash of all tunes
    def tunes() = @tunes ||= {}

    # https://github.com/aws/aws-sdk-ruby/blob/version-3/gems/aws-sdk-s3/lib/aws-sdk-s3/bucket.rb#L221
    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Bucket.html

    # Search tunes for concerns to extend a class that includes Concerns::Extendable
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
      logger.debug('Searching for', base_name)

      tunes.keys.each_with_object([]) do |plugin_name, ary|
        module_name = plugin_name.to_s.classify
        plugin_module_name = "#{module_name}::#{base_name}"
        next unless (plugin_module = plugin_module_name.safe_constantize)

        logger.debug('Found', plugin_module_name)
        # binding.pry if klass.eql?(RepositoriesController)
        # binding.pry if klass.eql?(Hendrix::MainController)
        # Ignore anything that is not an A/S::Concern
        next unless plugin_module.is_a?(ActiveSupport::Concern)

        logger.info('Extending', klass, 'from', plugin_module_name)
        ary.append(plugin_module)
      end
    end

    # Return an array of paths within loaded tunes that contain a file by name
    # Used by Generators to get an array of available templates
    def app_paths(type:, klass:, suffix: nil)
      type = type.to_s.pluralize
      klass = klass.to_s.singularize
      suffix = suffix&.to_s
      tunes.each_with_object([]) do |(name, plugin), ary|
        search_path = [type, name.to_s, klass, suffix].compact
        path = plugin.app_path.join(search_path)
        ary.append(path) if path.exist?
      end
    end

    # Use Zeitwerk to load classes in each tune's 'app' path
    def load_tunes
      tunes.values.each do |plugin|
        add_loader(name: :framework, path: plugin.gem_root.join('app'), notifier: plugin)
      end
    end
  end

  class Tune < Lyric
    class << self
      # https://github.com/rails/rails/blob/main/railties/lib/rails/application.rb#L68
      def inherited(base)
        name = name_from_base(base)
        return if base.to_s.eql?('Hendrix::Application')

        Hendrix.tunes[name] = base
        super
      end
    end
  end
end
