# frozen_string_literal: true

# monkeypatch Config gem's Options class
module Config
  class Options
    # TODO: Replace hardcoded '__' with value from Config
    # Underscored representation of a Config hash
    def to_env(key = '', value = self, ary = [])
      if value.is_a?(Config::Options)
        value.each_pair do |skey, value|
          to_env("#{key}#{key.empty? ? '' : '__'}#{skey}", value, ary)
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
  end
end
