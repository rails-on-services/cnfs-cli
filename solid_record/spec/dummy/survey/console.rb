# frozen_string_literal: true

module Infra
end

module SolidRecord
  class << self
    def su = Survey

    def survey_doc
      require_relative 'models/surveys'
      setup
      SolidRecord.toggle_callbacks { File.create(source: 'plural_doc/surveys.yml') }
    end

    def survey_path
      require_relative 'models/surveys'
      setup
      DirInstance.add(source: 'plural_path/surveys')
    end
  end
end
