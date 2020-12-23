# frozen_string_literal: false

class Hash
  # rubocop:disable Metrics/AbcSize
  def to_hcl(hash = self, spacer = 2, ary = [])
    max_key_length = hash.keys.max_by(&:length).length
    hash.stringify_keys!.sort.to_h.reject { |_k, v| v.nil? }.each_with_object(ary) do |(key, value), cary|
      val = __compute_hcl(value, spacer)
      key_join = "#{' ' * (max_key_length - key.length)} = "
      cary << ["#{' ' * spacer}#{key}", val].join(key_join)
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def __compute_hcl(value, spacer)
    case value
    when Array
      nary = value.each_with_object([]) { |item, ary| ary << __compute_hcl(item, spacer) }.join(', ')
      "[#{nary}]"
    when Hash
      value.any? ? "{\n#{to_hcl(value, spacer + 2).join("\n")}\n#{' ' * spacer}}" : '{}'
    when Integer, TrueClass, FalseClass
      value
    else
      delimiter = value.to_s.start_with?('module.') ? '' : "\""
      [delimiter, value.to_s.cnfs_sub, delimiter].join
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
