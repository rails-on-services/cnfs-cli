# frozen_string_literal: true

module Cnfs::Commands::Application
  class Backend::Deploy < Cnfs::Command
    register(Compose, :compose)
  end
end
