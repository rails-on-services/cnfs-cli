# frozen_string_literal: false

class Hash
  def to_hcl(hash = self, spacer = 2, ary = [])
    return ary if hash.keys.size.zero?

    max_key_length = hash.keys.max_by(&:length).length
    hash.stringify_keys.sort.to_h.each_with_object(ary) do |(key, value), cary|
      val = __hcl(value, spacer)
      key_join = "#{' ' * (max_key_length - key.length)} = "
      cary << ["#{' ' * spacer}#{key}", val].join(key_join)
    end
  end

  private

  def __hcl(value, spacer)
    case value
    when Array
      "[#{__hcl_array(value, spacer).join(', ')}]"
    when Hash
      "{#{__hcl_hash(value, spacer)}}"
    when Integer, TrueClass, FalseClass
      value
    else
      __hcl_string(value)
    end
  end

  def __hcl_array(value, spacer)
    value.each_with_object([]) do |item, ary|
      ary << __hcl(item, spacer)
    end
  end

  def __hcl_hash(value, spacer)
    return if value.empty?

    "\n#{to_hcl(value, spacer + 2).join("\n")}\n#{' ' * spacer}"
  end

  def __hcl_string(value)
    delimiter = value.match(Regexp.union(__hcl_string_no_delimiter)) ? '' : '"'
    [delimiter, value.to_s.cnfs_sub, delimiter].join
  end

  def __hcl_string_no_delimiter
    [/keys\(/, /element\(/, /module\./, /local\./]
  end
end
