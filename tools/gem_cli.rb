# frozen_string_literal: true
require 'fileutils'
require 'thor'
require 'active_support/inflector'

class Generator < Thor::Group
  include Thor::Actions
  argument :name

  def gemspec
    file_name = "cnfs-cli-#{name}.gemspec"
    remove_file(file_name) if self.class.name.eql?('NewGenerator')
    template('gemspec.rb', file_name)
  end

  private

  def metadata
    @metadata ||= Thor::CoreExt::HashWithIndifferentAccess.new({
      angular: {
        summary: 'the Angular Framework',
        description: 'create Angular repositories and services in CNFS project'
      },
      aws: {
        summary: 'Amazon Web Services',
        description: 'create CNFS compatible blueprints for AWS'
      },
      gcp: {
        summary: 'Google Cloud Platform',
        description: 'create CNFS compatible blueprints for GCP'
      },
      rails: {
        summary: 'the Ruby on Rails Framework',
        description: 'create RoR repositories and services in CNFS project'
      },
      cnfs_backend: {
        summary: 'CNFS Services',
        description: 'install service configurations into CNFS projects'
      },
    })
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
      remove_file("lib/cnfs/cli/#{name}.rb")
      template('lib/cnfs/cli/gem_name.rb', "lib/cnfs/cli/#{name}.rb")
      template('lib/cnfs/plugins/gem_name.rb', "lib/cnfs/plugins/#{name}.rb")
    end
  end

  private
end

class GemCli < Thor
  class_option :noop, desc: 'Do not execute commands',
    aliases: '-n', type: :boolean
  class_option :verbose, desc: 'Display extra information from command',
    aliases: '-v', type: :boolean

  desc 'new', 'Create new CLI plugin gem'
  def new(name)
    gem_name = "cnfs-cli-#{name}"
    exec("bundle gem #{gem_name}")
    FileUtils.mv(gem_name, name)
    generator = NewGenerator.new([name], {})
    generator.destination_root = "#{Dir.pwd}/#{name}"
    generator.invoke_all
    puts "\nDON'T FORGET TO UPDATE THE GEMSPEC SUMMARY AND DESCRIPTION"
  end

  desc 'build', 'Build all gems'
  def build
    each_dir do |name, gemspec|
      exec("gem build #{gemspec}")
    end
  end

  desc 'install', 'Install all gems locally from source'
  def install
    each_dir do |name, gemspec|
      exec("gem build #{gemspec}")
      next unless (gem = Dir['*.gem'].shift)

      exec("gem install ./#{gem}")
      FileUtils.rm(gem)
    end
  end

  desc 'uninstall', 'Uninstall all gems'
  def uninstall
    each_dir do |name, gemspec|
      exec("gem uninstall -a -x #{gemspec.delete_suffix('.gemspec')}")
    end
  end

  desc 'gemspec', 'Generate gemspecs for all gems'
  def gemspec
    each_dir do |name, gemspec|
      next if name.eql?('cli')

      begin
        generator = Generator.new([name], {})
        generator.invoke_all
      rescue => e
        puts e
        puts "Failed to generate gemspec for #{name}"
      end
    end
  end

  private

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
    `#{cmd}` unless options.noop
  end
end
