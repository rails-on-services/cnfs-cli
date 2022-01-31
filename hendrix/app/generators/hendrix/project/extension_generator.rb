# frozen_string_literal: true

module Hendrix
  class Project::ExtensionGenerator < ProjectGenerator
    def gem
      if options.noop
        puts cmd
        return
      end

      # These methods are not Thor aware and so execute in Dir.pwd
      # rather than #destination_root
      Pathname.new(name).rmtree if Pathname.new(name).exist?
      system(cmd)
      FileUtils.mv(gem_name, name)
    end

    def gem_libs
      remove_file("lib/#{gem_name_root}/#{name}.rb")
      template('templates/lib/module.rb.erb', "lib/#{gem_name_root}-#{name}.rb")
      template('templates/lib/plugin.rb.erb', "lib/#{gem_name_root}/#{name}/plugin.rb")
      inject_into_file "#{gem_name_root}-#{name}.gemspec",
        "  spec.add_dependency '#{gem_name_root}', '~> 0.1.0'\n", before: /^end/
    end

    def gem_root_files
      remove_file('Gemfile')
    end

    # renders templates
    def app_structure() = super

    def gem_cleanup
      return if options.noop

      if options.config
        remove_dir('.git')
        remove_file('.travis.yml')
        remove_file('.gitignore')
      end
    end

    private
    def manual_templates() = %w[lib/module.rb.erb lib/plugin.rb.erb]

    def cmd() = "bundle gem --test=rspec --ci=none --no-coc --no-rubocop --mit --changelog #{gem_name}"

    def gem_name() = "#{gem_name_root}-#{name}"

    def internal_path() = Pathname.new(__dir__)
  end
end
