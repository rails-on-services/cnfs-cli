require 'cnfs/ext/version'

module Cnfs
  module Ext
    class Error < StandardError; end

    class << self
      def gem_root; Pathname.new(File.expand_path('../../..', __FILE__)) end

      def autoload_dirs; @autoload_dirs ||= ["#{gem_root}/lib"] end
    end
  end
end
