# frozen_string_literal: true

# Creates a new CNFS Rails repository
# 1. Copy files into the root of the repository
# 2. Invoke 'rails plugin new' to create the repository's core gem (a template is invoked to modify generated files)
# 3. Invoke 'bundle gem' to create the repository's SDK gem (no template so all modifications are made in this file)
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/ClassLength
module Rails
  class RepositoryGenerator < Thor::Group
    include Thor::Actions
    include GeneratorConcern
    argument :project_name
    argument :repository_name

    def root_files
      in_root do
        template('cnfs/repository.yml.erb', 'cnfs/repository.yml')
        directory('files', '.')
      end
    end

    def services_gemfiles
      gemfile_extensions = ['', '.prod']
      gemfile_extensions.append('.dev') if options.source_repository
      in_root do
        gemfile_extensions.each do |env|
          template("services/Gemfile#{env}.erb", "services/Gemfile#{env}")
        end
      end
    end

    def dockerfiles
      dockerfile_extensions = ['']
      dockerfile_extensions.append('.dev') if options.source_repository
      in_root do
        dockerfile_extensions.each do |env|
          template("Dockerfile#{env}.erb", "Dockerfile#{env}")
        end
      end
    end

    def core_gem
      with_context('repository/core_generator.rb', 'lib', core_name, base_envs) do |env, exec_ary|
        system(env, exec_ary.join(' '))
        FileUtils.mv(core_name, 'core') unless core_name.eql?('core')
      end
    end

    def sdk_gem
      exec_string = ['bundle gem']
      exec_string.append('--exe --no-coc --no-mit')
      exec_string.append(sdk_name)
      Cnfs.logger.debug exec_string.join(' ')

      inside 'lib' do
        env = base_envs.transform_keys!(&:to_s)
        system(env, exec_string.join(' '))
        FileUtils.mv(sdk_name, 'sdk') unless sdk_name.eql?('sdk')
        inside 'sdk' do
          remove_directory('.git')
          remove_file('bin/console')
          str = v.size.positive? ? "require '#{v[0]}_sdk'" : ''
          template('bin/console.erb', 'bin/console')
          # TODO: Decide how to handle versioning
          # remove_file("lib/#{sdk_path}/version.rb")
        end
      end
    end

    no_commands do
      def v
        envs = source_envs(base_envs)
        envs.slice(:source_repo_name, :source_repo_path).values
      end
    end

    def sdk_gemfile_content
      str = v.size.positive? ? "gem '#{v[0]}_sdk', path: '#{v[1]}/lib/sdk'" : ''
      inside 'lib/sdk' do
        remove_file('Gemfile')
        template('Gemfile.erb', 'Gemfile')
      end
    end

    def sdk_lib_file_content
      inside 'lib/sdk/lib' do
        create_file "#{sdk_path}/models.rb"
        append_to_file "#{sdk_path}.rb", after: "version\"\n" do
          <<~HEREDOC
            require '#{sdk_path}/models'
          HEREDOC
        end
      end
    end

    def sdk_gemspec_content
      gemspec = "#{sdk_name}.gemspec"
      inside 'lib/sdk' do
        comment_lines(gemspec, 'require ')
        comment_lines(gemspec, 'require_relative ')
        gsub_file(gemspec, "#{sdk_path.classify}::VERSION", "'0.1.0'")
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

    def cnfs
      @cnfs ||= Thor::CoreExt::HashWithIndifferentAccess.new(base_envs.merge(source_envs(base_envs)).merge(service_envs))
    end

    def dockerfile_header
      ERB.new(File.read(template_path.join('Dockerfile.header.erb'))).result(binding)
    end

    def dockerfile_content
      ERB.new(File.read(template_path.join('Dockerfile.content.erb'))).result(binding)
    end

    def dockerfile_runtime_content
      ERB.new(File.read(template_path.join('Dockerfile.runtime.content.erb'))).result(binding)
    end

    def template_path
      views_path.join('templates')
    end

    def dockerfile_bundler
      @dockerfile_bundler ||= "bundler:#{`bundler version`.split[2]}"
    end

    # TODO: remove nokogiri
    def dockerfile_gems
      return 'nokogiri:1.10.10'

      @dockerfile_gems ||= begin
        gem_list.map do |gem|
          gem_name, version = `gem list -r "^#{gem}$" |tail -1`.strip.split
          "#{gem_name}:#{version.gsub('(', '').gsub(')', '')}"
        end.join(" \\\n    ")
      end
    end

    def gem_list
      %w[nokogiri ffi grpc mini_portile2 msgpack pg nio4r puma eventmachine]
    end

    def base_envs
      { repo_name: repository_name, repo_path: '../..', name: core_name }
    end

    def core_name
      @core_name ||= [*namespace, 'core'].join('_')
    end

    def sdk_path
      sdk_name.gsub('-', '/')
    end

    def sdk_name
      @sdk_name ||= [*namespace, 'sdk'].join('_')
    end

    # TODO: Move to repository model after refactoring models
    def namespace
      @namespace ||= set_namespace
    end

    # TODO: Move to repository model after refactoring models
    def set_namespace
      case options.namespace
      when 'project'
        [project_name, repository_name]
      when 'repository'
        [repository_name]
      else
        []
      end
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
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/ClassLength
