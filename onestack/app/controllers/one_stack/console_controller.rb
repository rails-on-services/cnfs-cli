# frozen_string_literal: true

# Rename pry commands so they still work but can be reassigned to CLI specific commands
%w[ls cd help].each do |cmd|
  Pry.config.commands["p#{cmd}"] = "Pry::Command::#{cmd.camelize}".constantize
  Pry.config.commands[cmd] = nil
end

Pry::Commands.block_command 'cd', 'change segment' do |path|
  if path.nil? || APP_CWD.relative_path_from(Cnfs.config.paths.segments).to_s.split('/').include?('..')
    path = '.' if path.nil?
    Object.send(:remove_const, :APP_CWD)
    APP_CWD = Cnfs.config.paths.segments
  end
  if (try_path = APP_CWD.join(path)).exist?
    Object.send(:remove_const, :APP_CWD)
    APP_CWD = try_path
    Cnfs.config.console.instance_variable_set('@context', nil)
    Cnfs.config.console.init_class
  end
end

Pry::Commands.block_command 'ls', 'list assets' do |*_args|
  Cnfs::Core.asset_names.each do |asset|
    next unless (names = Cnfs.config.console.context.send(asset.to_sym).pluck(:name)).any?

    puts names
  end
end

module OneStack::Projects
  class ConsoleController < OneStack::ApplicationController
    # include Hendrix::ConsoleController
    # include Concerns::ExecController

    before_execute :init, :init_class, :create_help

    if ENV['HENDRIX_CLI_ENV'].eql?('development')
      # Cnfs::Core.asset_names.each do |asset|
      #   delegate asset.to_sym, to: :context
      # end
    end

    def init_class() = self.class.init(options)

    # rubocop:disable Metrics/MethodLength
    def create_help
      Pry::Commands.block_command 'help', 'Show help for commands' do
        crud_cmds = %w[create edit list show destroy]
        cmds = crud_cmds.map { |cmd| "  #{cmd} [ASSET] [options]".ljust(35) + "# #{cmd.capitalize} asset" }

        controller_cmds = (Cnfs::MainController.all_commands.keys - %w[help project] - crud_cmds)
        cmds += controller_cmds.map { |cmd| "  #{cmd} [SUBCOMMAND] [options]".ljust(35) + "# Manage #{cmd.pluralize}" }

        cmds += [
          '  help [COMMAND]'.ljust(35) + '# Describe available commands or one specific command',
          '  reload!'.ljust(35) + '# Reload classes',
          '  reset!'.ljust(35) + '# Purge all records from the data store, reload classes and reload records'
        ]

        puts 'Commands:', cmds.sort, ''
      end
    end
    # rubocop:enable Metrics/MethodLength

    def reload!
      super
      @context = nil
      Node.source = :asset
      true
    end

    # Remove all records from the data store, reload classes and load segments into the data store
    def reset!
      Cnfs.data_store.reset
      reload!
      SegmentRoot.load
      true
    end

    class << self
      def init(options)
        @options = options
        @colors = nil
        @segmented_prompt = nil
      end

      def prompt
        proc do |obj, _nest_level, _|
          klass = obj.class.name.demodulize.delete_suffix('Controller').underscore
          label = klass.eql?('console') ? '' : " (#{obj.class.name})"
          "#{segmented_prompt}#{label}> "
        end
      end

      # rubocop:disable Metrics/AbcSize
      def segmented_prompt
        @segmented_prompt ||= Component.structs(@options).each_with_object([]) do |component, prompt|
          segment_type = Cnfs.config.cli.show_segment_type ? component.segment_type : nil
          segment_name = Cnfs.config.cli.show_segment_name ? component.name : nil
          next if (prompt_value = [segment_type, segment_name].compact.join(':')).empty?

          prompt_value = colorize(component, prompt_value) if Cnfs.config.cli.colorize
          prompt << prompt_value
        end.join('/')
      end
      # rubocop:enable Metrics/AbcSize

      def colorize(component, title)
        color = component.color
        color = color.call(component.name) if color&.class.eql?(Proc)
        colors.delete(color) if color
        color ||= colors.shift
        Pry::Helpers::Text.send(color, title)
      end

      # TODO: Sniff the monitor and use black if monitor b/g is white and vice versa
      def colors() = @colors ||= %i[blue green purple magenta cyan yellow red] #  white black]

      def shortcuts() = model_shortcuts.merge(super)

      def model_shortcuts
        { b: Builder, c: Context, co: Component, con: Configurator, d: Dependency, im: Image, n: Node,
          p: Plan, pr: Provider, pro: Provisioner, r: Resource, re: Repository, reg: Registry, ru: Runtime,
          s: Service, sr: SegmentRoot, u: User }
      end
    end
  end
end
