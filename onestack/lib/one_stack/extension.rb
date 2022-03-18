# frozen_string_literal: true

module OneStack
  class << self
    def extensions() = SolidApp.extensions
  end

  class Extension < SolidApp::Extension
    def self.gem_root() = Plugin.gem_root
  end
end
