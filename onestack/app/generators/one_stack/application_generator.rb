# frozen_string_literal: true

module OneStack
  class ApplicationGenerator < Hendrix::ApplicationGenerator

    # Argument order:
    # 1. Context is always received first
    # 2. Any additional arugments declared in sub-classes
    argument :context
  end
end
