# frozen_string_literal: true

class Hcl
  attr_accessor :content, :buffer

  def initialize(content, opts = {})
    opts = opts.with_indifferent_access.merge!(buffer: 2)
    @content = content
    @buffer = opts[:buffer]
  end

  # rubocop:disable Metrics/AbcSize
  def render(hash = content, spacer = buffer, ary = [])
    max_key_length = hash.keys.max_by(&:length).length
    hash.stringify_keys!.sort.to_h.reject { |_k, v| v.nil? }.each_with_object(ary) do |(key, value), cary|
      val = compute_val(value, spacer)
      key_join = ' ' * (max_key_length - key.length) + ' = '
      cary << ["#{' ' * spacer}#{key}", val].join(key_join)
    end
  end

  def compute_val(value, spacer)
    case value
    when Array
      nary = value.each_with_object([]) { |item, ary| ary << compute_val(item, spacer) }.join(', ')
      "[#{nary}]"
    when Hash
      value.any? ? "{\n#{render(value, spacer + buffer).join("\n")}\n#{' ' * spacer}}" : '{}'
    when Integer, TrueClass, FalseClass
      value
    else
      "\"#{value.to_s.cnfs_sub}\""
    end
  end
  # rubocop:enable Metrics/AbcSize
end

# rubocop:disable Style/BlockComments
=begin
  # def output_type
  #   if deploy_type.eql?(:instance)
  #     'this'
  #   elsif deploy_type.eql?(:kubernetes)
  #     '*'
  #   end
  # end

  # def title(name = nil)
  #   [@module_name, resource.name.gsub('_', '-'), name].compact.join('-')
  # end

  # def resource_config(target, resource, template, config = nil)
  #   ResourceRender.new(target, resource, template, config)
  # end

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

    def render_attributes(hash, spacer = 2, ary = [])
      max_key_length = hash.to_h.keys.max_by(&:length).length
      hash.transform_keys!(&:to_s).sort.to_h.each_with_object(ary) do |(key, value), cary|
        binding.pry if value.nil?
        val = compute_val(value, spacer)
        key_join = ' ' * (max_key_length - key.length) + ' = '
        cary << ["#{' ' * spacer}#{key}", val].join(key_join)
      end
    end

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
end
=end
# rubocop:enable Style/BlockComments
