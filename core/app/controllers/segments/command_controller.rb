# frozen_string_literal: true

module Segments
  class CommandController < Thor
    include Concerns::CommandController

    cnfs_class_options :dry_run, :init, :clean, :clean_all
    cnfs_class_options Cnfs.config.segments.keys

    desc 'console', 'Start a CNFS project console (short-cut: c)'
    def console() = execute
  end
end
