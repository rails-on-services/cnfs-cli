# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Generate < Cnfs::Command
    def self.mod(type)
      name.gsub('Cnfs', "cnfs/#{type}".camelize)
    end

    include mod(:rails).constantize if Object.const_defined?(mod(:rails))
    before_execute :crank

    def crank
      binding.pry
    end
  end
end
