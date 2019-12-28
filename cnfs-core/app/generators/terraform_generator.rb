# frozen_string_literal: true

class TerraformGenerator < GeneratorBase
  attr_accessor :resource

  def manifest
    generated_files = resources.each_with_object([]) do |resource, files|
      @resource = resource
      files << generate
    end
    FileUtils.rm(all_files - excluded_files - generated_files)
  rescue Thor::Error => e
    # TODO: add to errors array and have controller output the result
    puts e
    puts resource.to_json
  end

  private

  def views_path; super.join(target.provider.type.demodulize.underscore) end

  def generate
    tmpl = target.provider.resource_to_template(resource).to_s
    template("#{tmpl}.tf.erb", "#{target.write_path(path_type)}/#{[tmpl, resource.name].uniq.join('-')}.tf")
  end

  def excluded_files; Dir[target.write_path(path_type).join('terraform-provider*')] end

  def path_type; :infra end

  def resources; @resources ||= (target.resources + application.resources) end

  # def deploy_type; target.runtime.deploy_type end
  def deploy_type; :kubernetes end

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

  def render_config(defaults, resource_config: resource.config, target_config: target.tf_config)
    ResourceRender.new(resource, defaults.merge(target_config.merge(resource_config))).render
  end

  def render_attributes(hash, spacer = 2, ary = [])
    rr = ResourceRender.new(nil, nil)
    rr.render_attributes(hash, spacer, ary)
  end

  class ResourceRender
    attr_accessor :resource, :defaults, :resource_defaults

    def initialize(resource, defaults)
      @resource = resource
      @defaults = defaults
    end

    def render
      ret_val = render_attributes(defaults)
      if resource.resources
        ret_val << "\n  # Resources"
        res = YAML.load(resource.resources)
        ret_val << render_attributes(res, 2, [])
      end
      ret_val
    end

    def render_attributes(hash, spacer = 2, ary = [])
      max_key_length = hash.to_h.keys.max_by(&:length).length
      hash.transform_keys!(&:to_s).sort.to_h.each_with_object(ary) do |(key, value), ary|
        val = compute_val(value, spacer)
        key_join = ' ' * (max_key_length - key.length) + ' = '
        ary << ["#{' ' * spacer}#{key}", val].join(key_join)
      end
    end

    def compute_val(value, spacer)
      if value.is_a?(Array)
        nary = value.each_with_object([]) { |item, ary| ary << compute_val(item, spacer) }.join(', ')
        "[#{nary}]"
      elsif value.is_a?(Hash)
        "{\n#{render_attributes(value, spacer + 2).join("\n")}\n#{' ' * spacer}}"
      elsif value.is_a?(Integer) or [true, false].include?(value)
        value
      else
        "\"#{value}\""
      end
    end
  end
end
