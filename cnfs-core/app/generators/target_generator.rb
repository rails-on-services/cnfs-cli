# frozen_string_literal: true

class TargetGenerator < GeneratorBase
  def env
    empty_directory(write_path)
    template('env.erb', "#{write_path}/infra.env")
    # @environment = deployment.environment.merge!(deployment.application.environment.values.to_hash).merge!(
    #   target.environment.to_hash) # .merge!(target.runtime.to_hash)
    # template('env.erb', "#{write_path}/application.env") if environment and not environment.to_env.empty?
  end

  def targets
    target.layers.each do |layer|
      call('LayerGenerator', "#{write_path}/#{layer.name}", target, layer)
    end
  end

  private

  def environment; target.environment; end

  # def name; object.name; end
  # def class_name; object.class.name.underscore.gsub('/', '-'); end
end
