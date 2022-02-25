# frozen_string_literal: true

module SolidRecord
  # 'Top Level' Elements within a Document
  class RootElement < ModelElement
    delegate :pathname, to: :parent

    after_create :create_elements_in_path, if: -> { model_path.exist? }

    def create_elements_in_path() = elements.create(type: element_type, path: model_path.to_s, owner: model)

    def model_path() = @model_path ||= pathname.parent.join(model_key) # bling/groups.yml->asc => bling/asc

    def element_type() = 'SolidRecord::Path'
  end
end
