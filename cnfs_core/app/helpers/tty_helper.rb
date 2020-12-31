# frozen_string_literal: true

require 'forwardable'

module TtyHelper
  extend ActiveSupport::Concern
  extend Forwardable

  def_delegators :command, :run

  # The external commands runner
  #
  # @see http://www.rubydoc.info/gems/tty-command
  #
  # @api public
  def command(**options)
    options.merge!(uuid: false)
    options.merge!(dry_run: true) if Cnfs.project.options.dry_run
    # options.merge!(verbose: true) if project.options.verbose
    require 'tty-command'
    TTY::Command.new(options)
  end

  # The cursor movement
  #
  # @see http://www.rubydoc.info/gems/tty-cursor
  #
  # @api public
  def cursor
    require 'tty-cursor'
    TTY::Cursor
  end

  # Open a file or text in the user's preferred editor
  #
  # @see http://www.rubydoc.info/gems/tty-editor
  #
  # @api public
  def editor
    require 'tty-editor'
    TTY::Editor
  end

  # File manipulation utility methods
  #
  # @see http://www.rubydoc.info/gems/tty-file
  #
  # @api public
  def tty_generator
    require 'tty-file'
    TTY::File
  end

  # Terminal output paging
  #
  # @see http://www.rubydoc.info/gems/tty-pager
  #
  # @api public
  def pager(**options)
    require 'tty-pager'
    TTY::Pager.new(options)
  end

  # Terminal platform and OS properties
  #
  # @see http://www.rubydoc.info/gems/tty-pager
  #
  # @api public
  def host
    require 'tty-platform'
    TTY::Platform.new
  end

  # The interactive prompt
  #
  # @see http://www.rubydoc.info/gems/tty-prompt
  #
  # @api public
  def prompt(**options)
    require 'tty-prompt'
    TTY::Prompt.new(**options)
  end

  # Get terminal screen properties
  #
  # @see http://www.rubydoc.info/gems/tty-screen
  #
  # @api public
  def screen
    require 'tty-screen'
    TTY::Screen
  end

  # The unix which utility
  #
  # @see http://www.rubydoc.info/gems/tty-which
  #
  # @api public
  def which(*args)
    require 'tty-which'
    TTY::Which.which(*args)
  end

  # Check if executable exists
  #
  # @see http://www.rubydoc.info/gems/tty-which
  #
  # @api public
  def exec_exist?(*args)
    require 'tty-which'
    TTY::Which.exist?(*args)
  end

  # TODO: Integrate this method into standard flow
  def publish_results
    require 'tty-table'
    table = TTY::Table.new(%w[Commands Errors], errors.messages.to_a)
    output.puts "\n"
    output.puts table.render(:basic, alignments: %i[left left], padding: [0, 4, 0, 0])
  end
end
