# frozen_string_literal: true

module SolidRecord
  # 'Top Level' Elements within a Document
  class RootElement < Element
    delegate :pathname, to: :parent

    after_create :create_elements_in_path, if: -> { model_path.exist? }

    # def create_elements_in_path() = elements.create(type: element_type, path: model_path.to_s, owner: model, model_class_name: model_class_name)
    # def create_elements_in_path() = elements.create(type: element_type, path: model_path.to_s, owner: model, content_type: :associations)

    def create_elements_in_path
      binding.pry if model_class_name.eql?('Resource')
      segments << DirAssociation.create(parent: self, path: model_path.to_s, owner: model) # , content_type: :associations)
      # elements.create(type: 'SolidRecord::DirAssociation', path: model_path.to_s, owner: model) # , content_type: :associations)
    end

    def model_path() = @model_path ||= pathname.parent.join(model_key) # bling/groups.yml->asc => bling/asc

    # def element_type() = 'SolidRecord::Dir'
  end
end
