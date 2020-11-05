# frozen_string_literal: true

module Config
  class << self
    def load_file(path)
      options = load_files(path)
      options.__path__ = path
      options
    end
  end

  class Options
    attr_accessor :__path__

    # Return an array representation of the Config hash
    def to_array(key = '', value = self, ary = [])
      if value.is_a?(Config::Options)
        value.each_pair do |skey, value|
          # TODO: __ should not be hard coded
          to_array("#{key}#{key.empty? ? '' : '__'}#{skey}", value, ary)
        end
      else
        if value.is_a? Array
          ary.append("#{key.upcase}=#{value.join(',')}")
        else
          # TODO: cnfs_sub now takes an array of objects to send against
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

    def save(path = nil, values = self)
      self.__path__ = path unless path.nil?
      return unless __path__

      File.open(__path__, 'w') { |f| f.write(values.to_hash.deep_stringify_keys.to_yaml) }
    end
  end
end
