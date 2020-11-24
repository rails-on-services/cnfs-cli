# frozen_string_literal: true

module NamespacesHelper
  extend ActiveSupport::Concern

  included do
    include ExecHelper
    include TtyHelper
  end

  def before_execute
    project.process_manifests 
  end
end

