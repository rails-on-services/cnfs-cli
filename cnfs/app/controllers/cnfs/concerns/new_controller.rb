# frozen_string_literal: true

require 'active_support/concern'

module Cnfs::Concerns::NewController
  extend ActiveSupport::Concern

  included do
    include Cnfs::Concerns::CommandController
  end

  class_methods do
    def exit_on_failure?() = true
    # option :force,     desc: 'Force creation even if the project directory already exists',
    #   aliases: '-f', type: :boolean
    # option :config,    desc: 'Create project with a working configuration (instead of commented examples)',
    #   aliases: '-c', type: :boolean
    # option :guided,    desc: 'Create project with a guided configuration',
    #   aliases: '-g', type: :boolean
  end

  private

  def check_dir(name)
    if Dir.exist?(name) && !validate_destroy('Directory already exists. Destroy and recreate?')
      raise Cnfs::Error, set_color('Directory exists. exiting.', :red)
    end
    true
  end
end
