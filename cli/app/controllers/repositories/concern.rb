# frozen_string_literal: true

module Repositories
  module Concern
    extend ActiveSupport::Concern

    included do |base|

      private

      def with_context(name)
        Cnfs.paths.src.mkpath
        current_repo_count = Cnfs.paths.src.children.size
        yield
        if current_repo_count.zero?
          o = Config.load_file('cnfs.yml')
          o.repository = name
          o.save
        end
      end

      def update_config(name, config = {})
        o = Config.load_file(Cnfs.paths.config.join('repositories.yml'))
        o[name] = { config: config }
        o.save
      end
    end
  end
end
