# frozen_string_literal: true

# Rename pry commands so they still work but can be reassigned to CLI specific commands
%w[ls cd help].each do |cmd|
  Pry.config.commands["p#{cmd}"] = "Pry::Command::#{cmd.camelize}".constantize
  Pry.config.commands[cmd] = nil
end

Pry::Commands.block_command 'cd', 'change segment' do |path|
  puts "cd: invalid segment: #{path}" unless OneStack::Navigator.current.cd(path)
end

Pry::Commands.block_command 'pwd', 'print segment' do
  OneStack::Navigator.current.path.relative_path_from(OneStack.config.paths.segments).to_s
end

Pry::Commands.block_command 'ls', 'list current context assets' do |*args|
  asset_names = args.any? ? OneStack.config.asset_names.select{ |a| args.include?(a) } : OneStack.config.asset_names
  ab = asset_names.each_with_object({}) do |asset, hash|
    klass = "one_stack/#{asset}".classify.constantize
    abr = OneStack::ConsoleController.model_shortcuts.invert[klass]
    records = OneStack::Navigator.current.context.send(asset.to_sym)
    hash["#{asset} [#{abr}]"] = records.map{ |r| "#{r.name}#{r.type? ? " (#{r.type})" : ''}" }
  end
  puts TTY::Tree.new('.' => ab).render
end

module OneStack
  class ConsoleController < ApplicationController
    include SolidApp::ConsoleController

    before_execute :init, :nav, :create_help

    if ENV['HENDRIX_CLI_ENV'].eql?('development')
      # OneStack.config.asset_names.each do |asset|
      #   delegate asset.to_sym, to: :context
      # end
    end

    def create_help # rubocop:disable Metrics/MethodLength
      Pry::Commands.block_command 'help', 'Show help for commands' do
        crud_cmds = %w[create edit list show destroy]
        cmds = crud_cmds.map { |cmd| "  #{cmd} [ASSET] [options]".ljust(35) + "# #{cmd.capitalize} asset" }

        controller_cmds = (MainCommand.all_commands.keys - %w[help project] - crud_cmds)
        cmds += controller_cmds.map { |cmd| "  #{cmd} [SUBCOMMAND] [options]".ljust(35) + "# Manage #{cmd.pluralize}" }

        cmds += [
          '  help [COMMAND]'.ljust(35) + '# Describe available commands or one specific command',
          '  reload!'.ljust(35) + '# Reload classes',
          '  reset!'.ljust(35) + '# Purge all records from the data store, reload classes and reload records'
        ]

        puts 'Commands:', cmds.sort, ''
      end
    end

    def component() = context.component

    def reload!
      super
      Navigator.reload!
      nav
      true
    end

    # Remove all records from the data store, reload classes and load segments into the data store
    def reset!
      SolidRecord::DataStore.reset(*SolidRecord.config.load_paths)
      reload!
    end

    class << self
      def prompt
        proc do |obj, _nest_level, _|
          klass = obj.class.name.demodulize.delete_suffix('Controller').underscore
          label = klass.eql?('console') ? '' : " (#{obj.class.name})"
          "#{Navigator.current&.prompt}#{label}> "
        end
      end

      def shortcuts() = model_shortcuts.merge(super)

      def model_shortcuts
        { b: Builder, c: Context, co: Component, con: Configurator, d: Dependency, im: Image,
          p: Plan, pr: Provider, pro: Provisioner, r: Resource, re: Repository, reg: Registry, ru: Runtime,
          s: Service, sr: SegmentRoot, u: User }
      end
    end
  end
end
