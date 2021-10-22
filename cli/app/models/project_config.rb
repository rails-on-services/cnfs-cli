# frozen_string_literal: true

class ProjectConfig
  attr_accessor :config

  def initialize
    @config = Config.load_files('project.yml')
  end

  def command_options_for(klass, method)
    # Project.config.config.config.commands.repositories.create.options
    Project.config.config.config.commands[klass][method].options
  end
end
