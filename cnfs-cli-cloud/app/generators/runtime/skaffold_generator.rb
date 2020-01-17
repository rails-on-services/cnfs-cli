# frozen_string_literal: true

class Runtime::SkaffoldGenerator < RuntimeGenerator
  # TODO: generate image pull secrets file

  private

  def internal_path; Pathname.new(__dir__).join('..') end

  # TODO: get the pull secret sorted
  # def pull_secret; Stack.registry_secret_name end
  def pull_secret; 'test' end

  def pull_policy; 'Always' end
end
