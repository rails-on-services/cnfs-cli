# frozen_string_literal: true

module Services
  class PushController < ApplicationController
    cattr_reader :command_group, default: :image_operations

    def execute; end
  end
end
