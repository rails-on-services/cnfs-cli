# frozen_string_literal: true

class ProjectsController < Thor
  include Concerns::CommandController

  cnfs_class_options :dry_run, :init
  cnfs_class_options CnfsCli.config.segments.keys

  desc 'console', 'Start a CNFS project console (short-cut: c)'
  # map %w[c] => :console
  def console(*users) = execute
end
