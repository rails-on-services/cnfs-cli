# frozen_string_literal: true

# workaround for rails 6.0.0.beta2
application "require 'rails-html-sanitizer'"

remove_file 'config/master.key'
remove_file 'config/credentials.yml.enc'

insert_into_file 'config/application.rb', before: "\n# Require the gems" do
  <<~RUBY
    require 'ros/core'
  RUBY
end

inject_into_file 'config/application.rb', after: ".api_only = true\n" do
  <<-RUBY
  config.generators do |g|
    g.test_framework :rspec, fixture: true
    g.fixture_replacement :factory_bot, dir: 'spec/factories'
  end

  initializer 'service.set_platform_config', before: 'ros_core.load_platform_config' do |app|
    settings_path = root.join('config/settings.yml')
    Settings.prepend_source!(settings_path) if File.exist? settings_path
    name = self.class.name.split('::').first.underscore
    Settings.prepend_source!({ service: { name: name, policy_name: name.capitalize } })
    app.config.hosts << name
  end

  initializer 'service.initialize_infra_services', after: 'ros_core.initialize_infra_services' do |app|
  end

  initializer 'service.configure_console_methods', before: 'ros_core.configure_console_methods' do |_app|
    if Rails.env.development? and not Rails.const_defined?('Server')
      Ros.config.factory_paths += Dir[Pathname.new(__FILE__).join('../../../../spec/factories')]
    end
  end
  RUBY
end
