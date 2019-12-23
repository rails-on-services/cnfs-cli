# frozen_string_literal: true

module Infra
  class AwsGenerator < GeneratorBase
    attr_accessor :resource

    def manifest
        # binding.pry
      resources.each  do |resource|
        @resource = resource
        template("#{resource_to_template}.tf.erb", "#{target.write_path(:infra)}/#{resource_to_template}.tf")
      end
    rescue Thor::Error => e
      puts e
      puts resource.to_json
    end

    private

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

    def resource_to_template(res = resource)
      return res.name unless (type = res.type)
      key = type.demodulize.underscore.to_sym 
      {
        bucket: :s3,
        cdn: :cloudfront,
        cert: :acm,
        dns: :route53,
        redis: 'elasticache-redis'
      }[key] || key
    end
  end
end
