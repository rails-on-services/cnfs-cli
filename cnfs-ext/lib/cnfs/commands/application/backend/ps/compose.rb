# frozen_string_literal: true

module Cnfs::Commands::Application
  module Backend::Ps::Compose

    def self.included(base)
      base.include Cnfs::Commands::Compose
    end
  end
end
