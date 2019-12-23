require 'cnfs/ext/version'

module Cnfs
  module Ext
    class Error < StandardError; end

    class << self
      def gem_root; Pathname.new(File.expand_path('../../..', __FILE__)) end

      def autoload_dirs; @autoload_dirs ||= ["#{gem_root}/lib", "#{gem_root}/app/controllers"] end

      def after_initialize
        # App::BackendController.class_eval do
        #   desc 'zed IMAGE', 'Run tests on image(s)'
        #   include ::Ext::App::BackendController
        # end
      end
    end
  end
end
