# frozen_string_literal: true

class InfraGenerator < GeneratorBase
  # attr_accessor :force

  def manifests
    call(generator_class, "#{target.write_path(:infra)}", target)
  end

  private
  # def views_path; Pathname.new(internal_path).join("../views/infra/#{target.provider.type.demodulize.underscore}") end

  def generator_class; target.provider.type.gsub('Provider', 'Infra').underscore end
end
