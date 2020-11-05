# frozen_string_literal: true

module Primary
  class PushController < ApplicationController
    cattr_reader :command_group, default: :image_operations

    def execute; end
  end
end
