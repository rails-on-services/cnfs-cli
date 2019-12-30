# frozen_string_literal: true

class Application::CnfsBackend < Application
  store :config, accessors: %i[endpoints], coder: YAML

  def partition_name(env) # called by CredentialsController
    # TODO: CredentialsController needs to pass target.application_environment
    environment.dig(env, :platform, :partition_name)
  end

  # TODO: Rails service needs to pass target.application_environment
  def image_prefix(env); environment.dig(env, :rails_env) end

  # Called by RuntimeGenerator#application_environment
  def to_env(target = nil)
    @target = target

    env = Config::Options.new.merge!(environment.dig(:all))
    env.merge!(Config::Options.new.merge!(environment.dig(target.application_environment)).to_hash)
    env.merge!(entities_env(self))
    env.merge!(entities_env(target))
    env.merge!(target.to_env)
    env.empty? ? nil : env
  end

  def entities_env(owner)
    [owner.resources, owner.services, owner.resource_tags, owner.service_tags].each_with_object(Config::Options.new) do |entities, env|
      entities.each do |entity|
        next unless (entity_env = entity.to_env(target.application_environment, :application))

        env.merge!(entity_env.to_hash)
      end
    end.to_hash
  end

  # def old_one
  #   {{
  #       cdns: cdns,
  #       storage: {
  #         buckets: storage_buckets,
  #         config: { region: 'ap-southeast-1' },
  #         services: storage_services
  #       }
  #     }
  #   }
  # end

  # def cdns
  #   resources.where(type: 'Resource::Cdn').each_with_object({}) do |cdn, hash|
  #     hash[cdn.name] = {
  #       bucket: cdn.bucket,
  #       enabled: true,
  #       url: "https://#{cdn.hostname}.#{target.domain_name}"
  #     }
  #   end
  # end

  # def storage_buckets
  #   resources.where(type: 'Resource::Bucket').pluck(:name).each_with_object({}) do |n, hash|
  #     hash[n] = target.provider.storage.except(:endpoint).merge({
  #       name: "#{n}-#{target.domain_slug}",
  #       provider: target.provider.type.underscore.split('/').last
  #     })
  #   end
  # end

  # def storage_services
  #   resources.where(type: 'Resource::Bucket').each_with_object({}) do |resource, hash|
  #     resource.services.each { |service| hash[service] = resource.name }
  #   end
  # end
end
