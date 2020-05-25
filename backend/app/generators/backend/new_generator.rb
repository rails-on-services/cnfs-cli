# frozen_string_literal: true

# Creates a new cnfs backend project
module Backend
  class NewGenerator < Thor::Group
    include Thor::Actions
    argument :name

    def generate
      in_root do
        # TODO: Implement what needs to be in place here
        # directory('files', '.')
        # template 'Dockerfile'
      end
    end

    # TODO: move rails_options and plugin_options to a global config for .cnfs
    def generate_core
      rails_options = '--api -G -S -J -C -T -M --database=postgresql --skip-active-storage'
      plugin_options = '--full --dummy-path=spec/dummy'
      # generator = internal_path.join('../../views/rails/core/core_generator.rb')
      generator = internal_path.join('../rails/core_generator.rb')
      exec_system = "rails plugin new #{rails_options} #{plugin_options} -m #{generator} #{name}-core"
      puts exec_system
      inside('lib') do
        system exec_system
        FileUtils.mv "#{name}-core", 'core'
      end
    end

    def generate_sdk
      gem_options = '--exe --no-coc --no-mit'
      inside 'lib' do
        system "bundle gem #{gem_options} #{name}_sdk"
        FileUtils.mv "#{name}_sdk", 'sdk'
        FileUtils.rm_rf 'sdk/.git'
      end
    end

    def sdk_gemfile
      inside 'lib/sdk' do
        append_to_file 'Gemfile', after: "source \"https://rubygems.org\"\n" do
          <<~HEREDOC

            gem 'ros_sdk', path: '../../ros/lib/sdk'
            gem 'pry'
            gem 'awesome_print'
          HEREDOC
        end
        # remove_file "lib/#{name}_sdk/version.rb"
        remove_file 'bin/console'
        # template 'bin/console.erb', 'bin/console'
      end
    end

    def sdk_lib_file_content
      inside 'lib/sdk/lib' do
        create_file "#{name}_sdk/models.rb"
        append_to_file "#{name}_sdk.rb", after: "version\"\n" do
          <<~HEREDOC
            require '#{name}_sdk/models'
          HEREDOC
        end
      end
    end

    def sdk_gemspec_content
      gemspec = "#{name}_sdk.gemspec"
      klass = "#{name}_sdk".split('_').collect(&:capitalize).join
      inside 'lib/sdk' do
        comment_lines gemspec, 'require '
        gsub_file gemspec, "#{klass}::VERSION", "'0.1.0'"
        gsub_file gemspec, 'TODO: ', ''
        gsub_file gemspec, '~> 10.0', '~> 12.0'
        comment_lines gemspec, /spec\.homepage/
        comment_lines gemspec, /spec\.metadata/
        comment_lines gemspec, /spec\.files/
        comment_lines gemspec, '`git'
        # append_to_file gemspec, after: "when it is released.\n  " do <<~HEREDOC
        append_to_file gemspec, after: "s)/}) }\n" do
          <<~HEREDOC
            spec.files         = Dir['lib/**/*.rb', 'exe/*', 'Rakefile', 'README.md'].each do |e|
          HEREDOC
        end
      end
    end

    def cnfs_gems_repo
      return unless ENV['CNFS_DEV']

      in_root do
        `git clone https://github.com/rails-on-services/ros.git`
      end
    end

    # for each service gem, generate a rails application in ./services
    def cnfs_service_apps
      cnfs_service_names.each do |service_name|
        generator = Backend::ServiceGenerator.new([service_name], options)
        generator.destination_root = destination_root
        generator.cnfs_app = true
        generator.invoke_all
      end
    end

    private

    def cnfs_service_names
      %w[cognito comm iam organization storage]
    end

    def source_paths
      [views_path, views_path.join('templates')]
    end

    def views_path
      @views_path ||= internal_path.join('../../views/new')
    end

    def internal_path
      Pathname.new(__dir__)
    end

    # TODO: Fix these hard coded values to dynamic
    # def ruby_version
    #   '2.6.3'
    # end

    # def os_version
    #   'stretch'
    # end

    # def static_gems
    #   ['bundler:2.0.1',
    #    'nokogiri:1.10.3',
    #    'ffi:1.10.0',
    #    'mini_portile2:2.3.0',
    #    'msgpack:1.2.9',
    #    'pg:1.1.4',
    #    'nio4r:2.3.1',
    #    'puma:3.12.0',
    #    'eventmachine:1.2.7']
    # end

    # def gemfile_content
    #   ros_gems = ''
    #   if options.dev
    #     ros_gems = <<~'EOF'
    #       git 'git@github.com:rails-on-services/ros.git', glob: '**/*.gemspec', branch: :master do
    #         gem 'ros', path: 'ros/ros'
    #         gem 'ros-cognito', path: 'ros/services/cognito'
    #         gem 'ros-comm', path: 'ros/services/comm'
    #         gem 'ros-iam', path: 'ros/services/iam'
    #         gem 'ros-core', path: 'ros/lib/core'
    #         gem 'ros_sdk', path: 'ros/lib/sdk'
    #       end
    #     EOF
    #   end
    # end
  end
end
