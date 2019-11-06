# frozen_string_literal: true

module Cnfs::Core
  class Platform::Infra
    include Concerns::Partition

    def deployments; [:compose] end
  end
end
