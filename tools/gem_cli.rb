# frozen_string_literal: true

require 'fileutils'
require 'thor'
require 'yaml'
require 'active_support/inflector'

class Generator < Thor::Group
  include Thor::Actions
  argument :name

  def gemspec
    old_file_name = "cnfs_cli-#{name}.gemspec"
    file_name = "cnfs-cli-#{name}.gemspec"
    remove_file(old_file_name) if instance_of?(NewGenerator)
    template('gemspec.rb.erb', file_name)
  end

  private

  def metadata
    @metadata ||= YAML.load_file('tools/metadata.yml')
  end

  def source_paths
    ["#{__dir__}/new", "#{__dir__}/new/templates"]
  end
end

class NewGenerator < Generator
  def libs
    in_root do
      remove_dir('.git')
      remove_file('.travis.yml')
      directory('files', '.')
      remove_file("lib/cnfs_cli/#{name}.rb")
      template('lib/cnfs_cli/gem_name.rb.erb', "lib/cnfs_cli/#{name}.rb")
      template('lib/cnfs_cli/plugins/gem_name.rb.erb', "lib/cnfs_cli/plugins/#{name}.rb")
    end
  end
end

class GemCli < Thor
  class_option :force, desc: 'Overwrite existing dir if it exists',
                       aliases: '-f', type: :boolean
  class_option :noop, desc: 'Do not execute commands',
                      aliases: '-n', type: :boolean
  class_option :verbose, desc: 'Display extra information from command',
                         aliases: '-v', type: :boolean

  desc 'new', 'Create new CLI plugin gem'
  def new(name)
    FileUtils.rm_rf(name) if Dir.exist?(name) && validate_destroy('dir exists. Do you want to overwrite?')

    gem_name = "cnfs_cli-#{name}"
    exec("bundle gem -t none --ci=none --no-coc --no-rubocop --mit --changelog #{gem_name}")
    # exec("bundle gem #{gem_name}")
    FileUtils.mv(gem_name, name)
    generator = NewGenerator.new([name], {})
    generator.destination_root = "#{Dir.pwd}/#{name}"
    generator.invoke_all
    puts "\nDON'T FORGET TO UPDATE THE GEMSPEC SUMMARY AND DESCRIPTION"
  end

  desc 'build', 'Build all gems'
  def build
    each_dir do |_name, gemspec|
      exec("gem build #{gemspec}")
    end
  end

  desc 'install', 'Install all gems locally from source'
  def install
    each_dir do |_name, gemspec|
      exec("gem build #{gemspec}")
      next unless (gem = Dir['*.gem'].shift)

      exec("gem install ./#{gem}")
      FileUtils.rm(gem)
    end
  end

  desc 'uninstall', 'Uninstall all gems'
  def uninstall
    each_dir do |_name, gemspec|
      exec("gem uninstall -a -x #{gemspec.delete_suffix('.gemspec')}")
    end
  end

  desc 'gemspec', 'Generate gemspecs for all gems'
  def gemspec
    each_dir do |name, _gemspec|
      next if name.eql?('cli')

      begin
        generator = Generator.new([name], {})
        generator.invoke_all
      rescue StandardError => e
        puts e
        puts "Failed to generate gemspec for #{name}"
      end
    end
  end

  private

  def validate_destroy(msg = "\n#{'WARNING!!!  ' * 5}\nAction cannot be reversed\nAre you sure?")
    return true if options.force || yes?(msg)

    puts 'Operation cancelled'
    exit(-1)
  end

  def each_dir
    Dir['*/'].sort.each do |dir|
      dir = dir.delete_suffix('/')
      Dir.chdir(dir) do
        next unless (gemspec = Dir['*.gemspec'].shift)

        yield dir, gemspec
      end
    end
  end

  def exec(cmd)
    puts cmd if options.verbose
    system(cmd) unless options.noop
  end
end
