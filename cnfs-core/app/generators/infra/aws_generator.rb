# frozen_string_literal: true

module Infra
  class AwsGenerator < GeneratorBase
    attr_accessor :resource

    def manifest
      generated_files = resources.each_with_object([]) do |resource, generated_files|
        @resource = resource
        file = template("#{resource_to_template}.tf.erb",
                        "#{target.write_path(:infra)}/#{[resource_to_template.to_s, resource.name].uniq.join('-')}.tf")
        generated_files << file
      end
      excluded_files = Dir[target.write_path(:infra).join('terraform-provider*')]
      all_files = Dir[target.write_path(:infra).join('**/*')]
      FileUtils.rm(all_files - generated_files - excluded_files)
    rescue Thor::Error => e
      # TODO: add to errors array and have controller output the result
      puts e
      puts resource.to_json
    end

    private

    def title(name = nil)
      [@module_name, resource.name.gsub('_', '-'), name].compact.join('-')
    end

    def resource_to_template(res = resource)
      return res.template || res.name unless (type = res.type)
      key = type.demodulize.underscore.to_sym
      {
        bucket: :s3,
        cdn: :cloudfront,
        cert: :acm,
        dns: :route53,
        redis: 'elasticache-redis'
      }[key] || key
    end

    def views_path; super.join('provider/aws') end

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
end
