# frozen_string_literal: true

class DeploymentGenerator < GeneratorBase
  attr_accessor :force

  def generate
    @force = false
    deployment.targets.each do |target|
      write_path = [deployment.base_path, target.name, deployment.name].join('/')
      call('TargetGenerator', "#{write_path}/infra", target)
      call('ApplicationGenerator', "#{write_path}/app", target)
    end
  end
end
