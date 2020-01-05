# frozen_string_literal: true

module Config
  class Options
    # Return an array representation of the Config hash
    def to_array(target = nil, key = '', value = self, ary = [])
      if value.is_a?(Config::Options)
        value.each_pair do |skey, value|
          to_array(target, "#{key}#{key.empty? ? '' : Config.env_separator}#{skey}", value, ary)
        end
      else
        if value.is_a? Array
          ary.append("#{key.upcase}=#{value.join(",")}")
        else
          value = value.plaintext.cnfs_sub(target) if value.is_a? String
          ary.append("#{key.upcase}=#{value}") unless value.nil?
        end
      end
      ary
    end

    def to_cnfs
      to_h.stringify_keys.each_with_object({}) do |(key, value), hash|
        mkey = key.pluralize == key ? "#{key.singularize}_names" : "#{key}_name"
        hash[mkey] = value.index(',') ? value.split(',') : value
      end
    end
  end
end
