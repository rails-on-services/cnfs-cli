# frozen_string_literal: true

class InfraController < ApplicationController
  namespace :infra

  register Infra::BackendController, 'backend', 'backend [SUBCOMMAND]', 'Run backend commands'
end
