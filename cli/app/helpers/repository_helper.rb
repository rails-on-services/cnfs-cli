# frozen_string_literal: true

module RepositoryHelper
  extend ActiveSupport::Concern

  included do |_base|
    private

    def update_config(name, config = {})
      o = Config.load_file(Cnfs.paths.config.join('repositories.yml'))
      o[name] = { config: config }
      o.save
    end
  end
end
