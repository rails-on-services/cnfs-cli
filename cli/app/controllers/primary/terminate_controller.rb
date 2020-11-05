# frozen_string_literal: true

module Primary
  class TerminateController < ApplicationController
    def execute
      application.terminate
    end
  end
end
