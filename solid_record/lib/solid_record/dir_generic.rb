# frozen_string_literal: true

module SolidRecord
  class DirGeneric < Dir
    # 1. model_class_name is the default model_type if (class_map and pathname.name).safe_constantize fail
    # 2. process the documents: providers.yml, development.yml -> Component
    #
    def process_contents
      process_documents
      # process_dirs
    end

    def process_documents
      children.select(&:file?).each do |path|
        pathname_class = [namespace, path.name].compact.join('/').classify.safe_constantize&.to_s
        # content_type = pathname_class ? :plural : :singular
        # Files that are of a recognized class, eg providers.yml -> Provider are has_many
        # Files that are not recognized are a has_one
        file_class = pathname_class ? FileMany : FileOne
        this_model_type = class_map[path.name] || pathname_class || model_class_name
        # TODO: Perhaps the Document.create should be separate and raise first
        segments << file_class.create(parent: self, path: path.to_s,
                          model_class_name: this_model_type, owner: owner, namespace: namespace)
      end
    end

    def process_dirs
      children.select(&:directory?).each do |path|
        pathname_class = [namespace, path.name].compact.join('/').classify.safe_constantize&.to_s
        content_type = pathname_class ? :plural : :singular
        this_model_type = class_map[path.name] || pathname_class || model_class_name
        klass = pathname_class ? DirHasMany : DirInstance
        # TODO: If DirInstance then check if there is a Document of the same name
        # In fact, this should have already been processed by RootElement, but that needs to be checked
        # TODO: Perhaps the Document.create should be separate and raise first
        segments << klass.create(parent: self, path: path.to_s, content_type: content_type,
                          model_class_name: this_model_type, owner: owner)
      end
    end
  end
end
