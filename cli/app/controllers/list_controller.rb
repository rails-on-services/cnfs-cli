# frozen_string_literal: true

class ListController < Thor

  desc 'environments', 'list environments'
  def environments
    puts Cnfs.paths.config.join('environments').children.select{ |e| e.directory? }.map(&:to_s)
  end

  desc 'namespaces', 'list namespaces'
  def namespaces
    Cnfs.paths.config.join('environments').children.select{ |e| e.directory? }.each do |path|
      puts path.children.select{ |e| e.directory? }.map(&:to_s)
    end
  end

  desc 'repositories', 'list repositories'
  def repositories
    return unless Cnfs.paths.src.exist?

    puts Cnfs.paths.src.children.select{ |e| e.directory? }.map(&:to_s)
  end
end
