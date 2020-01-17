# frozen_string_literal: true

# Creates a new cnfs backend project
module Rails
  class NewGenerator < ApplicationGenerator
    argument :name

    def self.source_paths; [Pathname(File.dirname(__FILE__)).join('templates').to_s, File.dirname(__FILE__)] end

    def generate
      in_root do
        binding.pry
        # %x(git clone https://github.com/rails-on-services/ros.git)
      end # if false
      # directory('files', '.')
      # TODO: move to be specific
      # template 'Dockerfile'
      # empty_directory('services')
    end

    def generate_core
      return unless self.behavior.eql? :invoke

      template_file = Pathname.new(__dir__).join('../../views/rails/core/core_generator.rb')
      rails_options = '--api -G -S -J -C -T -M --database=postgresql --skip-active-storage'
      plugin_options = '--full --dummy-path=spec/dummy'
      exec_system = "rails plugin new #{rails_options} #{plugin_options} -m #{template_file} #{name}-core"
      puts exec_system
      inside('lib') do
        system exec_system
        FileUtils.mv "#{name}-core", 'core'
      end
    end

    def generate_sdk
      return unless self.behavior.eql? :invoke

      gem_options = '--exe --no-coc --no-mit'
      inside 'lib' do
        system "bundle gem #{gem_options} #{name}_sdk"
        FileUtils.mv "#{name}_sdk", 'sdk'
        FileUtils.rm_rf 'sdk/.git'
      end
    end

    # def remove_sdk
    #   return unless self.behavior.eql? :revoke
    #
    #   FileUtils.rm_rf("#{destination_root}/lib/sdk")
    #   say '      remove  lib/sdk'
    # end

    def sdk_gemfile
      inside 'lib/sdk' do
        append_to_file 'Gemfile', after: "source \"https://rubygems.org\"\n" do <<~HEREDOC

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
        append_to_file "#{name}_sdk.rb", after: "version\"\n" do <<~HEREDOC
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
        comment_lines gemspec, "`git"
        # append_to_file gemspec, after: "when it is released.\n  " do <<~HEREDOC
        append_to_file gemspec, after: "s)/}) }\n" do <<~HEREDOC
          spec.files         = Dir['lib/**/*.rb', 'exe/*', 'Rakefile', 'README.md'].each do |e|
          HEREDOC
        end
      end
    end

    private

    # TODO: Fix these hard coded values to dynamic
    def ruby_version; '2.6.3' end
    def os_version; 'stretch' end
    def static_gems
      ['bundler:2.0.1',
      'nokogiri:1.10.3',
      'ffi:1.10.0',
      'mini_portile2:2.3.0',
      'msgpack:1.2.9',
      'pg:1.1.4',
      'nio4r:2.3.1',
      'puma:3.12.0',
      'eventmachine:1.2.7']
    end

    def create_ros_services
      # TODO for each ros service gem, generate a rails application in ./services that includes that gem
      # TODO figure out how the ros services are written to a new project. they should be apps that include ros service gems
    end

    def gemfile_content
      ros_gems = ''
      if options.dev
        ros_gems = <<~'EOF'
        git 'git@github.com:rails-on-services/ros.git', glob: '**/*.gemspec', branch: :master do
          gem 'ros', path: 'ros/ros'
          gem 'ros-cognito', path: 'ros/services/cognito'
          gem 'ros-comm', path: 'ros/services/comm'
          gem 'ros-iam', path: 'ros/services/iam'
          gem 'ros-core', path: 'ros/lib/core'
          gem 'ros_sdk', path: 'ros/lib/sdk'
        end
        EOF
      end
    end
  end
end
