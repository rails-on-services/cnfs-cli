# frozen_string_literal: true

module OneStack
  class ApplicationView < Hendrix::ApplicationView
    def initialize(**options)
      # super(**default_options)
      super(**default_options.merge(options))
    end
  end
end
