# frozen_string_literal: true

module OneStack
  class ProjectsCommand < ApplicationCommand

    has_class_options :dry_run, :init, :clean, :clean_all, :tags
    has_class_options Hendrix.config.segments.keys

    desc 'console', 'Start a CNFS project console (short-cut: c)'
    def console(name = nil, *values)
      hash = { method: :execute } # Specify the method :execute to avoid method_missing being invoked on 'console'
      hash.merge!(name.to_sym => values) if name # filter the context asset specified in 'name' by values
      execute(**hash)
    end
  end
end
