# frozen_string_literal: true

module SolidRecord
  module Model
    extend ActiveSupport::Concern

    included do
      include Table
      include Persistence
      include Encryption
    end
  end
end
