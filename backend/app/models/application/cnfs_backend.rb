# frozen_string_literal: true

# TODO: This should probably move to the rails plugin
class Application::CnfsBackend < Application
  def partition_name(_env) # called by CredentialsController
    # TODO: CredentialsController needs to pass target.application_environment
    environment['all']['platform']['partition_name']
    # environment.dig(env, :platform, :partition_name)
  end

  # The image tag is specific to the CNFS services
  def image_tag(target)
    [version, image_prefix(target), git.sha].compact.join('-')
  end

  # TODO: Rails service needs to pass target.deployment.environment.rails_env
  def image_prefix(target)
    target.deployment.environment.dig(:rails_env)
  end

  # NOTE: Below code works, but trying to simplify config by having envs only from applicaiton, target and deployment
  # env.merge!(entities_env(self))
  # env.merge!(entities_env(target))

  # def entities_env(owner)
  #   [owner.resources, owner.services, owner.resource_tags, owner.service_tags].each_with_object(Config::Options.new) do |entities, env|
  #     entities.each do |entity|
  #       next unless (entity_env = entity.to_env(target.application_environment, :application))

  #       env.merge!(entity_env.to_hash)
  #     end
  #   end.to_hash
  # end
end
