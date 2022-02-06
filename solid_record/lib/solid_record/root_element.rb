# frozen_string_literal: true

module SolidRecord
  # 'Top Level' Elements within a Document
  class RootElement < ModelElement
    delegate :pathname, to: :parent

    after_create :create_path, if: -> { model_path.exist? }

    def create_path() = elements.create(type: element_type, path: model_path.to_s, owner: model)

    # bling/groups.yml => bling/asc
    def model_path() = @model_path ||= pathname.parent.join(model_name)

    # Override Element's delegation of root to parent as 'the buck stops here' at the RootElement
    def root() = self

    def update_document() = parent.update_document(self)

    def element_type() = 'SolidRecord::Path'
  end
end
