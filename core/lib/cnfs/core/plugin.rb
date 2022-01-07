# frozen_string_literal: true

module Cnfs
  module Core
    class Plugin < Cnfs::Plugin
      initializer 'cnfs data_store setup' do |app|
        Cnfs.data_store.add_models(Cnfs::Core.model_names)
        Cnfs.data_store.setup # if data_store
      end

      initializer 'node load' do |app|
        Cnfs.with_timer('load nodes') { SegmentRoot.load }
      end unless ENV['CNFS_CLI_ENV'].eql?('test')

      class << self
        def gem_root() = Cnfs::Core.gem_root
      end
    end
  end
end
