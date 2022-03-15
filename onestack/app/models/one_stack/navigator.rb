# frozen_string_literal: true

module OneStack
  # Manage the user's location within the segments directory hierarchy
  # Used by console to change directory and keep track of the contexts
  class Navigator
    attr_accessor :options, :args, :path

    def initialize(**kwargs) = kwargs.each { |k, v| send("#{k}=", v) }

    def context
      @context ||= Context.find_or_create_by(component: component_list.last) do |context|
        context.options = options
        context.components << component_list.slice(0, component_list.size - 1)
      end
    end

    def component_list() = @component_list ||= list

    # List hierarchy of components based on CLI options, cwd, ENV and default segment_name(s)
    def list # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      cwd_segments = path_segments.dup
      current = SegmentRoot.first
      components = [current]
      while current.components.any?
        next_segment = current.next_segment(options, cwd_segments.shift)
        break if next_segment.name.nil? # No search values found so stop at the current component

        unless next_segment.component
          OneStack.logger.warn([current.segments_type&.capitalize, "'#{next_segment.name}' specified by",
                                "*#{next_segment.source}* not found.",
                                "Context set to #{current.owner&.segments_type} '#{current.name}'"].join(' '))
          break
        end

        current = next_segment.component
        components << current
      end
      components
    end

    def path_segments() = path.relative_path_from(seg_path).to_s.split('/')

    def seg_path() = self.class.seg_path

    def structs() = component_list.each_with_object([]) { |comp, ary| ary.append(comp.struct) }

    def prompt # rubocop:disable Metrics/AbcSize
      @prompt ||= structs.each_with_object([]) do |component, prompt|
        segment_type = cli_config.show_segment_type ? component.segment_type : nil
        segment_name = cli_config.show_segment_name ? component.name : nil
        next if (prompt_value = [segment_type, segment_name].compact.join(':')).empty?

        prompt_value = colorize(component, prompt_value) if cli_config.colorize
        prompt << prompt_value
      end.join('/')
    end

    def cli_config() = OneStack.config.cli

    def colorize(component, title)
      color = component.color
      color = color.call(component.name) if color&.class.eql?(Proc)
      self.class.colors.delete(color) if color
      color ||= self.class.colors.shift
      Pry::Helpers::Text.send(color, title)
    end

    class << self
      attr_accessor :current
      attr_writer :navigators

      def cd(path) = new(path: path || seg_path, options: current.options, args: current.args)

      def new(**kwargs) # rubocop:disable Metrics/AbcSize
        %i[path options args].each { |attr| raise ArgumentError, "#{attr} required" unless kwargs.key?(attr) }

        path = Pathname.new(kwargs[:path])
        path = current_path.join(path) if path.relative?
        path = current_path unless path.exist?
        path = current_path if path.relative_path_from(seg_path).to_s.split('/').include?('..')
        kwargs[:path] = path

        @current = navigators[path.to_s] ||= super
      end

      def current_path() = current&.path || seg_path

      def seg_path() = OneStack.config.paths.segments

      def navigators() = @navigators ||= {}

      # TODO: Sniff the monitor and use black if monitor b/g is white and vice versa #  white black]
      def colors() = @colors ||= OneStack.config.cli.colors&.dup || %i[blue green purple magenta cyan yellow red]
    end
  end
end
