# frozen_string_literal: true

# Creates a new CNFS Rails repository
# 1. Copies files into the root of the repository
# 2. Creates a core gem (rails new plugin) for the repository
# 3. Creates an SDK gem (bundle gem) for the repository
module Rails
  class RepositoryGenerator < Thor::Group
    include Thor::Actions
    argument :project_name
    argument :name

    def root_files
      # return
      in_root do
        # Dockerfile, cnfs.yml, etc
        directory('files', '.')
        # ['', '.dev', '.prod'].each do |type|
        #   template("services/Gemfile#{type}.erb", "services/Gemfile#{type}")
        # end
        # ['', '.dev'].each do |type|
        #   # template("Dockerfile#{type}.erb", "Dockerfile#{type}")
        # end
      end
    end

    def core_gem
      gem_name = "#{project_name}_#{name}_core"
      exec_string = ['rails plugin new']
      exec_string.append('--api -G -S -J -C -T -M --database=postgresql --skip-active-storage')
      exec_string.append('--full --dummy-path=spec/dummy')
      exec_string.append('-m', internal_path.join('repository/core_generator.rb'), gem_name)

      env = {}
      puts env if options.debug
      puts exec_string.join(' ') if options.debug
      gemspec = "#{gem_name}.gemspec"

      inside('lib') do
        system(env, exec_string.join(' '))
        inside(gem_name) do
          gsub_file(gemspec, 'TODO: Write your name', `git config --get user.name`.chomp)
          gsub_file(gemspec, 'TODO: Write your email address', `git config --get user.email`.chomp)
          gsub_file(gemspec, '  spec.homepage', '  # spec.homepage')
          gsub_file(gemspec, 'TODO: ', '')
        end
        FileUtils.mv(gem_name, 'core')
      end
    end

    def sdk_gem
      exec_string = ['bundle gem']
      exec_string.append('--exe --no-coc --no-mit')
      exec_string.append(sdk_name)

      env = {}
      puts exec_string.join(' ') if options.debug

      inside 'lib' do
        system(env, exec_string.join(' '))
        FileUtils.mv(sdk_name, 'sdk')
        FileUtils.rm_rf('sdk/.git')
      end
    end

    # TODO: Path to ros sdk needs to be an ENV or taken from an ENV at time of creating this file
    def sdk_gemfile_content
      inside 'lib/sdk' do
        append_to_file 'Gemfile', after: "source \"https://rubygems.org\"\n" do
          <<~HEREDOC

            gem 'ros_sdk', path: '../../../ros/lib/sdk'
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
        create_file "#{sdk_name}/models.rb"
        append_to_file "#{sdk_name}.rb", after: "version\"\n" do
          <<~HEREDOC
            require '#{sdk_name}/models'
          HEREDOC
        end
      end
    end

    def sdk_gemspec_content
      gemspec = "#{sdk_name}.gemspec"
      klass = sdk_name.split('_').collect(&:capitalize).join
      inside 'lib/sdk' do
        comment_lines(gemspec, 'require ')
        comment_lines(gemspec, 'require_relative ')
        gsub_file(gemspec, "#{klass}::VERSION", "'0.1.0'")
        gsub_file(gemspec, 'TODO: ', '')
        gsub_file(gemspec, '~> 10.0', '~> 12.0')
        comment_lines(gemspec, /spec\.homepage/)
        comment_lines(gemspec, /spec\.metadata/)
        comment_lines(gemspec, /spec\.files/)
        comment_lines(gemspec, '`git')
        # append_to_file gemspec, after: "when it is released.\n  " do <<~HEREDOC
        append_to_file gemspec, after: "s)/}) }\n" do
          <<~HEREDOC
            spec.files         = Dir['lib/**/*.rb', 'exe/*', 'Rakefile', 'README.md'].each do |e|
          HEREDOC
        end
      end
    end

    private

    def sdk_name
      "#{project_name}_#{name}_sdk"
    end

    def source_paths
      [views_path, views_path.join('templates')]
    end

    def views_path
      @views_path ||= internal_path.join('repository')
    end

    def internal_path
      Pathname.new(__dir__)
    end
  end
end
