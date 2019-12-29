# frozen_string_literal: true

# monkeypatch Config gem's Options class
module Config
  class Options
    # TODO: Replace hardcoded '__' with value from Config
    # Underscored representation of a Config hash
    def to_array(key = '', value = self, ary = [])
      if value.is_a?(Config::Options)
        value.each_pair do |skey, value|
          to_array("#{key}#{key.empty? ? '' : '__'}#{skey}", value, ary)
        end
      else
        if value.is_a? Array
          ary.append("#{key.upcase}=#{value.join("\n")}")
        else
          ary.append("#{key.upcase}=#{value}") unless value.nil?
        end
      end
      ary
    end

    # def to_tf(hash = self, spacer = 2, ary = [])
    #   max_key_length = hash.to_h.keys.max_by(&:length).length
    #   # hash.transform_keys!(&:to_s).sort.to_h.each_with_object([]) do |(key, value), ary|
    #   hash.to_h.transform_keys!(&:to_s).sort.to_h.each_pair do |key, value|
    #     val = compute_val(value, spacer)
    #     key_join = ' ' * (max_key_length - key.length) + ' = '
    #     ary << ["#{' ' * spacer}#{key}", val].join(key_join)
    #   end
    #   ary
    # end

    # def compute_val(value, spacer)
    #   if [true, false].include?(value) or value.is_a?(Integer)
    #     value
    #   elsif value.is_a?(Config::Options)
    #     "{\n" + to_tf(value, spacer + 2).join("\n") + "\n#{' ' * spacer}}"
    #   elsif value.is_a?(Array)
    #     nary = value.each_with_object([]) do |item, ary|
    #       ary << compute_val(item, spacer)
    #     end
    #     "[#{nary.join(', ')}]"
    #   else
    #     "\"#{value}\""
    #   end
    # end
  end
end
