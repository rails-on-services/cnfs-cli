# frozen_string_literal: true

require 'cnfs/core/version'

require 'zeitwerk'
require 'config'
require_relative '../config/options'

module Cnfs
  class << self
    attr_accessor :platform, :settings

    def platform; @platform ||= Cnfs::Core::Platform.new end
    def settings; @settings ||= {} end
  end

  module Core
    class Error < StandardError; end

    class << self
      attr_accessor :autoload_dirs

      def config_dirs
        [gem_root.join('config'), Pathname.new(File.expand_path('config', Dir.pwd))]
      end

      def gem_root; Pathname.new(File.expand_path('../../..', __FILE__)) end

      def loader; @loader ||= Zeitwerk::Loader.new end

      # use Zeitwerk loader for class reloading
      def setup
        autoload_dirs.each { |dir| loader.push_dir(dir) }
        loader.enable_reloading
        loader.setup
      end

      def reload
        Cnfs.platform = nil
        Cnfs.settings = nil
        loader.reload
      end

      def autoload_dirs; @autoload_dirs ||= ["#{gem_root}/lib"] end # , "#{Cnfs.gem_root}/concerns", Cnfs.gem_root] end
    end
  end
end
