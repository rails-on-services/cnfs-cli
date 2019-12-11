# frozen_string_literal: true

class LayerGenerator < GeneratorBase
  def env
    template('env.erb', "#{write_path}/layer.env") unless environment.empty?
  end

  def services
    layer.services.each do |service|
      klass = service.type.nil? ? :service : service.type
      call(klass, write_path, target, layer, layer_type, service)
    end
  end

  private

  def environment
    layer.environment.self || {}
  end
end
