# frozen_string_literal: true

class SkaffoldGenerator < RuntimeGenerator
  # TODO: generate image pull secrets file

  private

  # TODO: get the pull secret sorted
  # def pull_secret; Stack.registry_secret_name end
  def pull_secret; 'test' end

  def pull_policy; 'Always' end
end
