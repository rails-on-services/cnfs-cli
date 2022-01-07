# frozen_string_literal: true

require_relative 'native/version'
require_relative 'native/plugin'

module Native
  module Concerns; end
end
module Ansible; end
module Proxmox; end
module Rest; end
module Vagrant; end

module Cnfs
  module Native
    def self.gem_root() = @gem_root ||= Pathname.new(__dir__).join('../..')
  end
end
