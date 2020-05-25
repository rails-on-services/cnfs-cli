# frozen_string_literal: true

module Config
  class Options
    # Return an array representation of the Config hash
    def to_array(key = '', value = self, ary = [])
      if value.is_a?(Config::Options)
        value.each_pair do |skey, value|
          to_array("#{key}#{key.empty? ? '' : '__'}#{skey}", value, ary)
        end
      else
        if value.is_a? Array
          ary.append("#{key.upcase}=#{value.join(',')}")
        else
          value = value.plaintext.cnfs_sub if value.is_a? String
          ary.append("#{key.upcase}=#{value}") unless value.nil?
        end
      end
      ary
    end

    def merge_many!(*ary)
      ary.each { |hash| merge!(Config::Options.new.merge!(hash).to_hash) }
      self
    end
  end
end
