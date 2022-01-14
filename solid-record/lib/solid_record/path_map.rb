# frozen_string_literal: true

module SolidRecord

  # path: 'spec/dummay/data'
  # layout:
  # backend/development
  # backend/production/cluster
  # frontend/cluster
  #
  # 1. Single class at all levels of hierarchy (i.e. self referencing)
  #    Required models: Segment
  #    map: { '.' => 'segments' }
  #
  # 2. Consistent map of hierarchy paths to classes
  #    Required models Stack, Environment, Target
  #    map: { '.' => 'stacks', 'stacks' => 'environments', 'stacks/environments' => 'targets' }
  #    map: 'stacks/environments/targets'
  #
  #    map: 'stacks/backend' => environments'
  #    map: 'stacks/frontend' => targets'
  #
  # 3. Each path within the hierarchy has it's own class hierarchy
  #    Required models Stack, Environment, Target
  #    map: { '.' => 'stacks', 'frontend' => 'target', 'backend' => 'environments', backend/production' => 'target' })
  #
  # 4. Default
  #    Required models: path.basename.to_s.classify
  #    map: {}
  #
  class << self
    attr_writer :path_maps, :glob_pattern, :path_map

    # array of PathMap classes
    def path_maps() = @path_maps ||= []

    def glob_pattern() = @glob_pattern ||= '**/*.yml'
  end

  class PathMap
    attr_accessor :path, :map, :pattern

    def initialize(**options)
      @path = Pathname.new(options.fetch(:path, '.'))
      @map = options.fetch(:map, nil)
      @pattern = options.fetch(:pattern, SolidRecord.glob_pattern)
      @recursive = options.fetch(:recursive, false)
    end

    def load_path
      path.glob(pattern).each do |childpath|
        unless (klass = resolve(childpath))
          puts "Resolve #{childpath} failed"
          next
        end

        # puts "Resolve #{childpath} to #{klass.name}"
        if klass.respond_to? :load_content
          klass.load_content(childpath)
        else
          puts "Class #{klass.name} does not respond to :load_content"
        end
      end
    end

    def resolve(childpath)
      type_path = childpath.relative_path_from(path)
      type_path.classify.safe_constantize
    end

    class << self
      def load
        path_maps = SolidRecord.path_maps || []
        path_maps.append({}) if path_maps.empty?
        path_maps.each { |hash| new(**hash).load_path }
      end
    end
  end

  class MyPathMap < PathMap
    def resolve(childpath)
      type_path = childpath.relative_path_from(path)
      if (klass = type_path.classify.safe_constantize)
        return klass
      elsif (klass = type_path.parent.classify.safe_constantize)
        return klass
      else
        puts "MyPathMap Resolve #{childpath} failed"
      end
    end
  end

  class MyPathMap2 < PathMap
    def resolve(childpath)
      map = @map&.split('/')
      type_path = entry.relative_path_from(path)
      if map
        if recursive
          type_path = Pathname.new(map.join('/'))
        else
          type_path = type_path.to_s.split('/')[map.size..]
          type_path = Pathname.new((map + type_path).join('/'))
        end
        puts childpath, type_path
      end
    end
  end
end
