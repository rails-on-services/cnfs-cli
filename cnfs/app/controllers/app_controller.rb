# frozen_string_literal: true

class AppController < ApplicationController
  namespace :application

  register App::BackendController, 'backend', 'backend [SUBCOMMAND]', 'Run backend commands'
  register App::FrontendController, 'frontend', 'frontend [SUBCOMMAND]', 'Run frontend commands'
  register App::PipelineController, 'pipeline', 'pipeline [SUBCOMMAND]', 'Run frontend commands'
end
