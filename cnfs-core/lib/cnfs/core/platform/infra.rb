# frozen_string_literal: true

module Cnfs::Core
  class Platform::Infra
    include Concerns::Partition

    def deployments
      Config::Options.new({ dev_local: { orchestrator: :compose } })
    end
  end
end
