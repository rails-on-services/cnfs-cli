# frozen_string_literal: true

# Map names of Files and Dirs to recognized classes in the order of priority:
# 1. config.class_map, 2. path.name and 3. model_class_name (default)
# Files with recognized mappings will have instances of that class created
# For Dirs
#
# 1. model_class_name is the default model_type if (class_map and pathname.name).safe_constantize fail
# 2. process the documents: providers.yml, development.yml -> Component
module SolidRecord
  class DirGeneric < Dir
    def process_contents
      process(:file?) do |class_name|
        # Files that are of a recognized class, eg providers.yml -> Provider are has_many
        # Files that are not recognized are a has_one
        [File, { content_format: (class_name ? :plural : :singular) }]
      end
      process(:directory?) do |class_name|
        [class_name ? DirHasMany : DirGeneric, {}]
      end
    end

    def classic(name) = [namespace, name].compact.join('/').classify.safe_constantize&.to_s

    def process(filter)
      children.select(&filter).each do |path|
        class_name = classic(class_map[path.name] || path.name)

        klass, hash = yield(class_name)
        create_segment(klass, hash.merge(path: path.to_s, model_class_name: class_name || model_class_name))

        # hash.merge!(path: path.to_s, model_class_name: class_name || model_class_name)
        # create_segment(klass, hash)
        # TODO: If DirInstance then check if there is a File of the same name
        # In fact, this should have already been processed by RootElement, but that needs to be checked
      end
    end
  end
end
