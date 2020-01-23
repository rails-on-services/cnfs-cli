# frozen_string_literal: true

# Creates a new service in a cnfs backend project
module Rails
  class ServiceGenerator < ApplicationGenerator
    argument :name

    def self.source_paths
      ["#{File.dirname(__FILE__)}/templates", File.dirname(__FILE__)]
    end

    # TODO: db and dummy path are set from config values
    def generate
      return unless behavior.eql? :invoke

      return if Dir.exist?("services/#{name}")

      rails_generator = is_ros? ? 'plugin' : 'app'
      plugin = is_ros? ? 'plugin' : ''
      plugin_options = is_ros? ? '--full --dummy-path=spec/dummy' : ''

      # template_file = "#{File.dirname(__FILE__)}/#{rails_generator}/#{rails_generator}_generator.rb"
      template_file = Pathname.new(__dir__).join("../../views/rails/#{rails_generator}/#{rails_generator}_generator.rb")
      binding.pry

      rails_options = '--api -G -S -J -C -T -M --skip-turbolinks --database=postgresql --skip-active-storage'
      exec_string = "rails #{plugin} new #{rails_options} #{plugin_options} -m #{template_file} #{name}"
      puts exec_string
      FileUtils.mkdir_p("#{destination_root}/services")
      Dir.chdir("#{destination_root}/services") { system(exec_string) }
    end

    # def revoke
    #   return unless self.behavior.eql? :revoke

    #   FileUtils.rm_rf("#{destination_root}/services/#{name}")
    #   say "      remove  services/#{name}"
    # end

    # TODO: maybe move this to plugin
    def gemspec_content
      return unless is_ros?

      gemspec = "services/#{name}/#{name}.gemspec"
      gsub_file gemspec, '  spec.name        = "', '  spec.name        = "ros-'
    end

    def sdk_content
      create_file "#{sdk_lib_path}/models/#{name}.rb", <<~RUBY
        # frozen_string_literal: true

        module #{platform_name.split('_').collect(&:capitalize).join}
          module #{name.split('_').collect(&:capitalize).join}
            class Client < Ros::Platform::Client; end
            class Base < Ros::Sdk::Base; end

            class Tenant < Base; end
          end
        end
      RUBY

      append_file "#{sdk_lib_path}/models.rb", <<~RUBY
        require '#{platform_name}_sdk/models/#{name}.rb'
      RUBY
    end

    private

    def is_ros?
      true
    end

    def platform_name
      File.basename(Dir["#{lib_path.join('sdk')}/*.gemspec"].first).gsub('_sdk.gemspec', '')
    end

    def lib_path
      Pathname(destination_root).join('lib')
    end

    def sdk_lib_path
      lib_path.join("sdk/lib/#{platform_name}_sdk")
    end
  end
end
