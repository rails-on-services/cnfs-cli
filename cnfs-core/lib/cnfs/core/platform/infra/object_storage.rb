# frozen_string_literal: true

module Cnfs::Core
  class Platform::Infra::ObjectStorage
    include Concerns::Resource

    def p
      providers[config.provider].credentials.to_env
    end

    class Bucket
      attr_accessor :name, :services

      def initialize(name, config)
        @name = name
        @services = config[:services]
      end
    end

    def buckets
      ary = []
      settings.buckets.to_hash.each_pair do |name, config|
        ary << Bucket.new(name, config)
      end
      ary
    end

    def bucket_names; settings.buckets.keys end
          # Common environment for application services
          def application_environment
            {
              infra: {
                provider: cluster.config.provider,
              },
              platform: {
                feature_set: current_feature_set,
                infra: {
                  resources: {
                    storage: {
                      buckets:
                      infra.settings.components.object_storage.components.each_with_object({}) do |(name, config), hash|
                        hash[name] = Hash.new
                        hash[name]['name'] = "#{name}-#{bucket_base}"
                        config.to_hash.reject { |key| key.eql?(:services) }.each_pair { |key, value| hash[name][key] = value }
                      end,
                      services:
                      infra.settings.components.object_storage.components.each_with_object({}) do |(name, config), hash|
                        config.services.each do |dir|
                          hash[dir] = "#{name}"
                        end
                      end
                    },
                    cdns: infra.settings.components.cdn.components.to_hash
                  }
                }
              }
            }
          end
  end
end
