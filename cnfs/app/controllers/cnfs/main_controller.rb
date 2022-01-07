# frozen_string_literal: true

module Cnfs
  class MainController < Thor
    include Cnfs::Concerns::Extendable if defined? APP_ROOT

    def self.exit_on_failure?() = true
  end
end
