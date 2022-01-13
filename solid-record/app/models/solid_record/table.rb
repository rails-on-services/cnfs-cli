# frozen_string_literal: true

module SolidRecord
  class << self
    # Registry of models that have included the Persistence module
    def models() = @models ||= []
  end

  module Table
    extend ActiveSupport::Concern

    included do
      SolidRecord.models << self
    end
  end
end
