# frozen_string_literal: true

class ApplicationRecord < Cnfs::ApplicationRecord
  self.abstract_class = true

  store :config, coder: YAML

  class << self
    def permitted_scopes
      @permitted_scopes ||= %i[config environments environment namespace].to_set
    end
  end
end
