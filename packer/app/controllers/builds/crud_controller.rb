# frozen_string_literal: true

module Builds
  class CrudController
    include ExecHelper
    include TtyHelper

    def apply
      return unless (build = Build.find_by(name: args.name))

      write_it(build) do
        command.run!({ 'PACKER_CACHE_DIR' => Cnfs.project.cache_path.to_s },
                     "packer build --force #{build.packer_file}")
      end
    end

    def create
      build = Build.new(project: Cnfs.project)
      build.view.send(__method__)
      unless build.valid?
        puts build.errors.join("\n")
        return
      end
      build.save
      write_it(build)
    end

    # TODO: Test this method
    def delete
      return unless (build = Build.find_by(name: args.name))

      build.destroy
    end

    def describe
      return unless (build = Build.find_by(name: args.name))

      write_it(build)
      puts File.read(build.execute_path.join(build.packer_file))
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def list
      require 'tty-tree'
      data = Build.order(:name).each_with_object({}) do |build, hash|
        hash[build.name] = children = []
        children.append(
          { builders: build.builders.map{ |b| "#{b.name} (#{b.type.demodulize})" } }
        ) if build.builders.any?
        children.append(
          { provisioners: build.provisioners.order(:order).map{ |b| "#{b.name} (#{b.type.demodulize})" } }
        ) if build.provisioners.any?
        children.append(
          { 'post-processors': build.post_processors.order(:order).map{ |b| "#{b.name} (#{b.type.demodulize})" } }
        ) if build.post_processors.any?
      end
      data = { Cnfs.project.name => [data] }
      puts TTY::Tree.new(data).render
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def update
      return unless (build = Build.find_by(name: args.name))

      build.view.send(__method__)
      unless build.valid?
        puts build.errors.join("\n")
        return
      end
      build.save
      write_it(build)
    end

    def write_it(build)
      build.execute_path.mkpath unless build.execute_path.exist?
      Dir.chdir(build.execute_path) do
        BuildGenerator.new([build], options).invoke_all
        build.render
        yield if block_given?
      end
    end
  end
end
