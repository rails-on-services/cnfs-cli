# frozen_string_literal: true

module Services
  class TerminateController < ApplicationController
    def execute
      application.terminate
    end
  end
end
