# frozen_string_literal: true

class DeploymentGenerator < GeneratorBase
  attr_accessor :force

  def env
    template('env.erb', "#{target.write_path}/deployment.env") unless environment.empty?
  end

  def manifests
    @force = false
    call(:application, "#{target.write_path}/application", target)
    call(:target, "#{target.write_path}/target", target)
  end

  private

  def environment
    deployment.environment.self || {}
  end
end
