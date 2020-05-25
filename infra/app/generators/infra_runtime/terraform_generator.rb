# frozen_string_literal: true

class InfraRuntime::TerraformGenerator < InfraRuntimeGenerator
  private

  def generate
    tmpl = entity_to_template.to_s
    template("#{tmpl}.tf.json.erb", "#{context.write_path(path_type)}/#{tmpl}.tf.json") if @blueprint.valid?
  end

  def entity_template_map
    context.target.provider.resource_to_terraform_template_map
  end

  def excluded_files
    Dir[context.write_path(path_type).join('terraform-provider*')] +
      Dir[context.write_path(path_type).join('terraform.tfstate*')]
  end

=begin
  # def deploy_type; target.runtime.deploy_type end
  def deploy_type
    :kubernetes
  end

  def output_type
    if deploy_type.eql?(:instance)
      'this'
    elsif deploy_type.eql?(:kubernetes)
      '*'
    end
  end

  def title(name = nil)
    [@module_name, resource.name.gsub('_', '-'), name].compact.join('-')
  end

  def resource_config(target, resource, template, config = nil)
    ResourceRender.new(target, resource, template, config)
  end

  # def render_attributes(hash, spacer = 2, ary = [])
  #   rr = ResourceRender.new(nil, nil, nil)
  #   rr.render_attributes(hash, spacer, ary)
  # end

  class ResourceRender
    attr_accessor :target, :resource, :template, :xtra_config, :config

    def initialize(target, resource, template, xtra_config)
      @target = target
      @resource = resource
      @template = template
      @xtra_config = xtra_config || {}
      @config = template.merge(target.tf_config.merge(resource.config.merge(@xtra_config)))
    end

    def render
      render_attributes(config)
    end

    # rubocop:disable Metrics/AbcSize
    def render_attributes(hash, spacer = 2, ary = [])
      max_key_length = hash.to_h.keys.max_by(&:length).length
      hash.transform_keys!(&:to_s).sort.to_h.each_with_object(ary) do |(key, value), cary|
        binding.pry if value.nil?
        val = compute_val(value, spacer)
        key_join = ' ' * (max_key_length - key.length) + ' = '
        cary << ["#{' ' * spacer}#{key}", val].join(key_join)
      end
    end
    # rubocop:enable Metrics/AbcSize

    def compute_val(value, spacer)
      if value.is_a?(Array)
        nary = value.each_with_object([]) { |item, ary| ary << compute_val(item, spacer) }.join(', ')
        "[#{nary}]"
      elsif value.is_a?(Hash)
        "{\n#{render_attributes(value, spacer + 2).join("\n")}\n#{' ' * spacer}}"
      elsif value.is_a?(Integer) || [true, false].include?(value)
        value
      else
        "\"#{value.cnfs_sub}\""
      end
    end
  end
=end
end
