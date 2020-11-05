# frozen_string_literal: true

class NewController
  attr_accessor :name, :options

  def initialize(name, options)
    @name = name
    @options = options
  end

  def execute
    generator = NewGenerator.new([name], options)
    generator.destination_root = name
    generator.invoke_all

    Dir.chdir(name) do
      Cnfs.reset
      add_environments
      # add_backend if options.backend
      # add_dev_repos if options.dev
    end
  end

  def add_environments
    %w[development staging production].each do |env|
      ComponentAddController.new([], options.merge(project_name: name)).environment(env)
      ComponentAddController.new([], options.merge(project_name: name, environment: env)).namespace('main')
    end
  end

  # def add_backend
  #   repo_name = "#{name}-backend".gsub('-', '_')
  #   ComponentAddController.new([], options.merge(type: 'rails')).repository(repo_name)
  # end

  # def add_dev_repos
  #   cnfs_repo_name = 'cnfs-backend'
  #   ComponentAddController.new([], options.merge(url: 'git@github.com:rails-on-services/ros.git')).repository(cnfs_repo_name)
  # end

  # TODO: if options.dev pass in the appropriate vars
  # %w[iam cognito].each do |service_name|
  #   service_options = options.merge(repository: repo_name, wrap: "#{cnfs_repo_name}/#{service_name}")
  #   ComponentAddController.new([], service_options).service(service_name)
  # end
end
