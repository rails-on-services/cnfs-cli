# frozen_string_literal: true

module Infra
  # class BackendController < Thor
  class BackendController < ApplicationController
    # namespace 'application backend' #:backend
    class_option :verbose, type: :boolean, default: false, aliases: '-v'
    class_option :debug, type: :numeric, default: 0, aliases: '--debug'
    class_option :noop, type: :boolean, aliases: '-n'
    class_option :help, aliases: '-h', type: :boolean, desc: 'Display usage information'

    class_option :deployment, type: :string, aliases: '-d'
    class_option :target, type: :string, aliases: '-t'
    class_option :layer, type: :string, aliases: '-l'

    desc 'create', 'Create target infrastructure'
    def create(*args); run(:create, args) end

    desc 'generate', 'Generate target infrastructure'
    def generate(*args); run(:generate, args) end
  end
end
