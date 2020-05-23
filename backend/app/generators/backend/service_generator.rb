# frozen_string_literal: true

# Creates a new service in a cnfs backend project
module Backend
  class ServiceGenerator < Thor::Group
    include Thor::Actions
    argument :name

    # TODO: db and dummy path are set from config values
    def generate
      if behavior.eql? :revoke
        inside('services') { empty_directory(name) }
        return
      end

      return if Dir.exist?("services/#{name}")

      plugin = is_dev? ? 'plugin' : ''
      plugin_options = is_dev? ? '--full --dummy-path=spec/dummy' : ''
      rails_options = '--api -G -S -J -C -T -M --skip-turbolinks --database=postgresql --skip-active-storage'

      generator_type = is_dev? ? 'plugin' : 'app'
      # template_file = internal_path.join("../../views/rails/#{rails_generator}/#{rails_generator}_generator.rb")
      template_file = internal_path.join("../rails/#{generator_type}_generator.rb")

      exec_string = "rails #{plugin} new #{plugin_options} #{rails_options} -m #{template_file} #{name}"
      puts exec_string
      inside('services') { system(exec_string) }
    end

    def gemspec_content
      return unless is_dev?

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

    def is_dev?
      !Cnfs.application.config.dev
    end

    def platform_name
      File.basename(Dir["#{lib_path.join('sdk')}/*.gemspec"].first).gsub('_sdk.gemspec', '')
    end

    def sdk_lib_path
      lib_path.join("sdk/lib/#{platform_name}_sdk")
    end

    def lib_path
      Pathname.new(destination_root).join('lib')
    end

    def source_paths
      [views_path, views_path.join('templates')]
    end

    def views_path
      @views_path ||= internal_path.join('../views/rails/plugin')
    end

    def internal_path
      Pathname.new(__dir__)
    end
  end
end
