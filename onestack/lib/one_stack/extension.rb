# frozen_string_literal: true

module OneStack
  class << self
    def extensions() = Hendrix.extensions
  end

  class Extension < Hendrix::Extension
    def self.gem_root() = Plugin.gem_root
  end
end
