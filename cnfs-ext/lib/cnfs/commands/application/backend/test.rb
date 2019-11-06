# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Test < Cnfs::Command
    register(Compose, :compose)
  end
end

