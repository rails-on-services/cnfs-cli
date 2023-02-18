# frozen_string_literal: true

module SolidRecord
  def self.survey = Survey
end

class Survey
  class << self
    def plural_doc
      require_relative 'models'
      SolidRecord.setup
      SolidRecord.toggle_callbacks { SolidRecord::File.create(source: 'survey/plural_doc/surveys.yml') }
    end

    def plural_path
      require_relative 'models'
      SolidRecord.setup
      SolidRecord::DirInstance.add(source: 'survey/plural_path/surveys')
    end
  end
end
