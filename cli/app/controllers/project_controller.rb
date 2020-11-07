# frozen_string_literal: true

class ProjectController < CommandsController
  desc 'console', 'Start a CNFS project console (short-cut: c)'
  map %w[c] => :console
  def console
    run(:console)
  end

  desc 'init', 'Initialize the project'
  long_desc <<-DESC.gsub("\n", "\x5")

  The 'cnfs init' command initializes a newly cloned CNFS project with the following operations:

  Clone repositories
  Check for dependencies
  DESC
  def init
    run(:init)
  end

  desc 'customize', 'Customize project templates'
  def customize
    Cnfs.invoke_plugins_wtih(:customize)
  end
end
