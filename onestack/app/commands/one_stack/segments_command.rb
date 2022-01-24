# frozen_string_literal: true

module OneStack
  class SegmentsCommand < ApplicationCommand
    has_class_options :dry_run, :init, :clean, :clean_all
    has_class_options Hendrix.config.segments.keys

    desc 'console', 'Start a OneStack project console (short-cut: c)'
    def console() = execute
  end
end
