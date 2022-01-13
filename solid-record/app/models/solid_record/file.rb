# frozen_string_literal: true

module SolidRecord
  class << self
    # SolidRecord.parser = :yaml
    def parser() = nil
  end

  module File
    # Persistence
    # TODO: Maybe this, or some part of it, goes to the parent class to share between dir and file
    def create_owner(owner)
      asset_content.each do |name, values|
        asset_type = singular? ? parent.bname : shortname
        unless (klass = asset_type.to_s.classify.safe_constantize)
          Cnfs.logger.warn('Error on', asset_type)
          next
        end

        # TODO: Log it if not valid like it is today
        c = klass.create(values.merge(name: name, owner: owner, node: self))
        # binding.pry unless c.persisted?
      end
    end

    def self.create_content(object:)
      parent_node = object.owner.node.segment_dir
      file_name = parent_node.pathname.join("#{object.class.table_name}.yml").to_s
      node = find_or_create_by(parent: parent_node, path: file_name)
      current_content = file_content || {}
      writable_content = current_content.merge(object.name => object.node_content).sort.to_h
      node.write(writable_content)
    end

    def update_content(object:)
      if singular?
        write(object.name => object.node_content)
      else
        write(file_content.merge(object.node_content))
      end
    end

    def destroy_content(object:)
      if singular? || file_content.keys.size.eql?(1)
        destroy
      else
        write(file_content.except(object.name))
      end
    end

    def asset_content() = solid_path.singular? ? { send(SolidRecord.key_column) => solid_path.solid_read } : solid_path.solid_read

    # def singular?() = asset_names.exclude?(shortname)

    # If the file is empty YAML returns false so override this to return an empty hash when file is empty
    def file_content() = super || {}

    def asset_names() = Cnfs.config.asset_names

  end
end
