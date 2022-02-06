# frozen_string_literal: true

module SolidRecord
  class << self
    def document_map
      {
        yml: :yaml,
        yaml: :yaml
      }
    end
  end

  class Document < Association
    include FileSystemElement

    def values() = @values ||= pathname.singular? ? { pathname.name => read } : read

    def read() = send("read_#{doc_type}")

    def update_document(root_element)
      content = send("read_#{serializer}".to_sym, root_element)
      # TODO: JSON.parse(content.to_json)) 
      send("write_#{doc_type}".to_sym, content) # JSON.parse(content.to_json)) # convert to json to remove Ruby object annotations
    end

    def read_array(root_element)
      values.reject { |r| r[root_element.key_column].eql?(root_element.model_name) }.append(root_element.to_solid)
    end

    # def read_hash(root_element) = values.except(root_element.model_name).merge(root_element.to_solid)
    def read_hash(root_element) = values.merge(root_element.to_solid)

    # def write_content(element)
    #   pathname.singular? ? elements.first.to_solid : send("write_#{serializer}".to_sym, element)
    # end

    # def write_array(w_element)
    #   binding.pry
    #   elements.each_with_object([]) do |element, ary|
    #     ary.append(element.model.to_solid)
    #   end
    # end

    # def write_hash(w_element)
    #   col = w_element.model_class.key_column
    #   v = values.except(w_element.model.send(col))
    #   # h = element.elements.map(&:to_solid)
    #   # elements.where.not( id: element.id)
    #   binding.pry
    #   elements.each_with_object({}) do |element, hash|
    #     hash.merge! element.model.to_solid
    #   end
    # end

    # def write(content = nil)
    #   send("write_#{doc_type}") if content
    # end

    # Return a type based on the file's extension, e.g. .yml or .yaml returns a :yaml
    # based on the vlaues of the SolidRecord.document_map hash
    def doc_type
      unless (doc_type = document_map[pathname.extension])
        SolidRecord.raise_or_warn(DocumentTypeError.new("Document type for #{pathname.extension} not found"))
      end
      doc_type
    end

    def document_map() = @document_map ||= SolidRecord.document_map.with_indifferent_access

    def read_yaml() = YAML.load_file(path) || {}

    def write_yaml(content) = pathname.write(content.to_yaml)

    # Used by Assocation when creating ModelElements
    def element_type() = 'SolidRecord::RootElement'

    def tree_label() = pathname.name
  end
end
