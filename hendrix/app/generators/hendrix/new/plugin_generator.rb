# frozen_string_literal: true

module Hendrix
  class New::PluginGenerator < NewGenerator
    def gem
      if options.noop
        puts cmd
      else
        system(cmd)
        FileUtils.mv(gem_name, name)
      end
    end

    # All Thor methods are automatically invoked inside destination_root
    def set_root() = self.destination_root = name

    def component_files() = _component_files

    def libs
      if options.config
        remove_dir('.git')
        remove_file('.travis.yml')
        remove_file('.gitignore')
      end
      remove_file("lib/cnfs/#{name}.rb")
      remove_file('Gemfile')
      template('templates/Gemfile.erb', 'Gemfile')
      template('templates/lib/cnfs/module.rb.erb', "lib/cnfs/#{name}.rb")
      template('templates/lib/cnfs/plugin.rb.erb', "lib/cnfs/#{name}/plugin.rb")
    end

    # def gemspec
    #   in_root do
    #     old_file_name = "cnfs_cli-#{name}.gemspec"
    #     file_name = "cnfs-#{name}.gemspec"
    #     remove_file(old_file_name)
    #     template('templates/gemspec.rb.erb', file_name)
    #   end
    # end

    private

    def cmd() = "bundle gem --test=rspec --ci=none --no-coc --no-rubocop --mit --changelog #{gem_name}"

    def gem_name() = "cnfs-#{name}"

    def internal_path() = Pathname.new(__dir__)
  end
end
