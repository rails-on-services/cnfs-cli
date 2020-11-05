# frozen_string_literal: true
# 1. core lib for an application repository (template name is core_generator)
# 2. core lib for a plugin repository (template name is core_generator)
# 3. a service for a plugin repository (template name is generator)
#
# 1. application stand alone (CNFS_WRAP is NOT present)
# 2. application that wraps a plugin from a plugin repository (CNFS_WRAP is present)

class Profile
  attr_accessor :name, :lib_path, :platform_name, :service_name, :module_name, :module_string
  attr_accessor :app_dir, :config_file, :initializer_file, :routes_file
  attr_accessor :ros_path, :ros_lib_path
  attr_accessor :is_engine, :is_ros
  attr_accessor :username, :email, :service_type

  def initialize(name, generator, options)
    repository_root = 
    # self.repository_name = 'whistler'
    # self.code_type = 'service' || 'core'
    # self.service_name = 'outcome' || 'iam' || 'core'
    # self.service_type = 'plugin' || 'application'
    # self.wrapped_repository_name = 'ros'
    # self.wrapped_service_name = 'iam'
    #
    self.name = name
    self.is_engine = (options.full || options.mountable)
    self.lib_path = Pathname('../../lib')
    if File.basename(options.template).eql?('core_generator.rb')
      self.platform_name = name.gsub('-core', '')
    else
      platform_path = is_engine? ? Pathname(generator.destination_root).join('../../lib') : lib_path
      self.platform_name = File.basename(Dir["#{platform_path.join('sdk')}/*.gemspec"].first).gsub('_sdk.gemspec', '')
    end
    self.service_name = name
    self.module_name = service_name.classify
    self.is_ros = platform_name.eql?('ros')
    self.module_string = is_engine? ? module_name : 'Ros'
    self.app_dir = is_engine? ? "#{options.dummy_path}/" : '.'
    self.config_file = is_engine? ? "lib/#{name.gsub('-', '/')}.rb" : 'config/application.rb'
    self.initializer_file = is_engine? ? "lib/#{name.gsub('-', '/')}/engine.rb" : 'config/application.rb'
    self.routes_file = "#{app_dir}/config/routes.rb"
    # TODO: this should be calculated if this is an engine or not
    self.ros_path = "../../../#{ENV['CNFS_WRAP']}"
    self.ros_lib_path = "#{ros_path}/lib"
    self.username = `git config user.name`.chomp
    self.email = `git config user.email`.chomp
  end

  def is_engine?
    is_engine
  end

  def is_ros?
    is_ros
  end
end
