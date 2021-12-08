# frozen_string_literal: true

class New::PluginGenerator < NewGenerator
  def gem
    self.destination_root = name
    gem_name = "cnfs_cli-#{name}"
    cmd = "bundle gem -t none --ci=none --no-coc --no-rubocop --mit --changelog #{gem_name}"

    if options.noop
      puts cmd
      return
    end

    system(cmd)
    FileUtils.mv(gem_name, name)
  end

  def gemspec
    in_root do
      old_file_name = "cnfs_cli-#{name}.gemspec"
      file_name = "cnfs-cli-#{name}.gemspec"
      remove_file(old_file_name)
      template('templates/gemspec.rb.erb', file_name)
    end
  end

  def libs
    in_root do
      if options.config
        remove_dir('.git')
        remove_file('.travis.yml')
        remove_file('.gitignore')
      end
      directory('files', '.')
      remove_file("lib/cnfs_cli/#{name}.rb")
      template('templates/lib/cnfs_cli/module.rb.erb', "lib/cnfs_cli/#{name}.rb")
      template('templates/lib/cnfs_cli/plugins/class.rb.erb', "lib/cnfs_cli/plugins/#{name}.rb")
    end
  end

  def message
    Cnfs.logger.warn "\nDON'T FORGET TO UPDATE THE GEMSPEC SUMMARY AND DESCRIPTION"
  end

  private

  def internal_path() = Pathname.new(__dir__)

  def metadata
    {}
  end
end
