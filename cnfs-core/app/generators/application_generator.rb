# frozen_string_literal: true

class ApplicationGenerator < GeneratorBase
  def env
    empty_directory(write_path)
    template('env.erb', "#{write_path}/app.env")
  end

  def layers
    application.layers.each do |layer|
      call('LayerGenerator', "#{write_path}/#{layer.name}", target, layer)
    end
  end

  private

  def environment; application.environment end
end
