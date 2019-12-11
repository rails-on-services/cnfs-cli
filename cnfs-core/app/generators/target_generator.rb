# frozen_string_literal: true

class TargetGenerator < GeneratorBase
  def env
    empty_directory(write_path)
    template('env.erb', "#{write_path}/infra.env") unless environment.empty?
  end

  def layers
    target.layers.each do |layer|
      call(:layer, "#{write_path}/#{layer.name}", target, layer, :target)
    end
  end

  def runtime
    call(target.runtime.type.underscore, write_path.to_s.gsub('deployments', 'runtime'), target)
  end

  private

  def environment
    target.environment.self || {}
  end
end
