# frozen_string_literal: true

module SolidRecord
  module Model
    extend ActiveSupport::Concern

    included do
      include Persistence
      include Associations
    end
  end
end
