# frozen_string_literal: true

class ApplicationView < Cnfs::ApplicationView
  def initialize(**options)
      # super(**default_options)
      super(**default_options.merge(options))
  end
end
