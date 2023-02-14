# frozen_string_literal: true

module SolidRecord
  class << self
    # Registry of models that have included this module
    def tables() = @tables ||= []
  end

  module Table
    extend ActiveSupport::Concern

    included do
      SolidRecord.tables << self
    end
  end
end
