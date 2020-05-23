# frozen_string_literal: true

class Profile
  attr_accessor :name, :lib_path, :platform_name, :service_name, :module_name, :module_string
  attr_accessor :app_dir, :config_file, :initializer_file, :routes_file
  attr_accessor :ros_path, :ros_lib_path
  attr_accessor :is_engine, :is_ros

  def initialize(name, generator, options)
    self.name = name
    self.is_engine = (options.full || options.mountable)
    self.lib_path = Pathname('../../lib')
    if File.basename(options['template']).eql?('core_generator.rb')
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
    self.ros_path = '../../ros'
    self.ros_lib_path = "#{ros_path}/lib"
  end

  def is_engine?
    is_engine
  end

  def is_ros?
    is_ros
  end
end
